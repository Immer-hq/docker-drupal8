'use strict';

const Fs = require('fs');
const exec = require('child_process').exec;

let composerJson = Fs.readFileSync('/var/www/composer.json').toString();

function escapeRegExp(str) {
  return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
}

exec('drush ups --format=csv | { grep "`drush php-eval "print t(\'SECURITY UPDATE available\');"`" || true; }', {
  cwd: '/var/www/web'
}, (err, result) => {
  if (err) {
    console.error('Error while fetching updates:', err);
    process.exit(1);
  }

  let count = 0;

  result.split('\n').filter(item => item).map(item => {
    const parts = item.split(',');
    let project;
    let version;
    if (parts[0] === 'drupal') {
      // Core has a different version numbering.
      project = 'core';
      version = parts[2];
    } else {
      project = parts[0];
      version = parts[2].replace('8.x-', '');
    }
    return {project, version};
  }).filter(item => {
    const exclude = (process.env.exclude || '').split(',');
    return exclude.indexOf(item.project) < 0;
  }).forEach(item => {
    ++count;
    const {project, version} = item;
    const pattern = new RegExp(escapeRegExp(`"drupal/${project}"`) + ':[\\s]+"[^"]+"');
    composerJson = composerJson.replace(pattern, `"drupal/${project}": "${version}"`);
  });

  if (count === 0) {
    console.error('No security updates found');
    process.exit(0);
  }

  Fs.writeFileSync('/var/www/composer.json', composerJson);
  exec('composer update', {
    cwd: '/var/www'
  }, (err, result) => {
    if (err) {
      console.error('Error installing updates:', err);
      process.exit(1);
    }
    console.error('Updates succesfully installed');
    console.log('Changed: /var/www/composer.json => /composer.json');
    console.log('Changed: /var/www/composer.lock => /composer.lock');
  });
});
