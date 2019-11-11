'use strict';

const exec = require('child_process').exec;

function escapeRegExp(str) {
  return str.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
}

exec('php /var/scripts/security-checker.phar security:check /var/www/composer.lock --format=json', {
  cwd: '/var/www'
}, async (err, result) => {
  // Tool returns code 1 when updates are available.
  if (err.code > 1) {
    console.error('Error while fetching updates:', err);
    process.exit(1);
  }

  result = JSON.parse(result);
  const packages = typeof result === 'object' && !Array.isArray(result) ? Object.keys(result) : [];

  const update = packages.filter(name => {
    const exclude = (process.env.exclude || '').split(',');
    return exclude.indexOf(name) < 0 && exclude.indexOf(name.replace('drupal/', '')) < 0;
  });

  if (update === 0) {
    console.error('No security updates found');
    process.exit(0);
  }

  for (let i = 0; i < update.length; ++i) {
    const name = update[i];
    await new Promise(resolve => {
      exec(`composer require ${name} --update-with-dependencies --no-progress`, {
        cwd: '/var/www'
      }, err => {
        if (err) {
          console.error('Error installing updates:', err);
          process.exit(1);
        }
        resolve();
      });
    });
  }

  console.error('Updates succesfully installed');
  console.log('Changed: /var/www/composer.json => /composer.json');
  console.log('Changed: /var/www/composer.lock => /composer.lock');
});
