module.exports = {
  title: 'Cozie Apple',
  tagline: 'Cozie Apple - an IOS app for human comfort data collection',
  url: 'https://your-docusaurus-test-site.com',
  baseUrl: '/',
  favicon: 'img/favicon.ico',
  organizationName: 'BEARS', // Usually your GitHub org/user name.
  projectName: 'cozie-apple', // Usually your repo name.
  themeConfig: {
    navbar: {
      title: 'Cozie Apple',
      logo: {
        alt: 'Cozie Apple Logo',
        src: 'img/logo.svg',
      },
      links: [
        {
          to: 'docs/',
          activeBasePath: 'docs',
          label: 'Docs',
          position: 'left',
        },
        {to: 'blog', label: 'Blog', position: 'left'},
        {
          href: 'https://github.com/FedericoTartarini',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Style Guide',
              to: 'docs/',
            },
            {
              label: 'Second Doc',
              to: 'docs/doc2/',
            },
          ],
        },
        {
          title: 'Community',
          items: [
            {
              label: 'SinBerBEST',
              href: 'https://sinberbest.berkeley.edu',
            },
            {
              label: 'BUDS Lab',
              href: 'https://www.budslab.org',
            },
            {
              label: 'Twitter',
              href: 'https://twitter.com/FedericoTartar1',
            },
          ],
        },
        {
          title: 'More',
          items: [
            {
              label: 'Blog',
              to: 'blog',
            },
            {
              label: 'GitHub',
              href: 'https://github.com/FedericoTartarini',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Cozie Apple, BEARS and BUDS Lab. Built with Docusaurus.`,
    },
  },
  presets: [
    [
      '@docusaurus/preset-classic',
      {
        docs: {
          // It is recommended to set document id as docs home page (`docs/` path).
          homePageId: 'doc1',
          sidebarPath: require.resolve('./sidebars.js'),
          // Please change this to your repo.
          editUrl:
            'https://github.com/facebook/docusaurus/edit/master/website/',
        },
        blog: {
          showReadingTime: true,
          // Please change this to your repo.
          editUrl:
            'https://github.com/facebook/docusaurus/edit/master/website/blog/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      },
    ],
  ],
};
