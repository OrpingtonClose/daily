yarn global add vuepress

vuepress dev
vuepress build

npm init

echo -e '# Wecome to Example.com\n\nWe hope you love this tiny tiny site.' > README.md
echo '# Hello VuePress' >> README.md
echo '# Lunch menu' >> README.md
echo '# Dinner menu' >> README.md
mkdir something
echo -e '# Welcome to to Example.com\n\nWe hope you love this tiny tiny site.\n\nNeed to [contact someone](./contact.md) on the team?'  >> README.md

cat - >> herp.md <<EOF
# Top level header, aka H1

H1 is the most important header.

## Second level header

This gets converted to an H2

### Third-level header

VuePress indexes only up to H3 for its searches

#### Level 4 header, aka H4

People remember only about 3 levels of a hierarchy

##### H5

Who goes this low? and why?

###### H6

A level 6 header is used only by spelunkers.

Normal text isn't indexed by VuePress's internal search.
EOF


npm i vuepress --save
npm i webpack-dev-middleware@3.6.0 --save
./node_modules/.bin/vuepress dev

