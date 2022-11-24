module.exports = {
  title: "Cozie - An iOS application for IEQ and physiological data collection",
  tagline: "Allows building occupants to provide feedback in real time",
  url: "https://cozie-apple.app",
  baseUrl: "/",
  favicon: "img/favicon.ico",
  organizationName: "cozie-app", // Usually your GitHub org/user name.
  projectName: "cozie-apple", // Usually your repo name.
  themeConfig: {
    navbar: {
      title: "Cozie",
      logo: {
        alt: "Cozie Logo",
        src: "img/logo-round.png",
      },
      items: [
        {
          to: "docs/",
          activeBasePath: "docs",
          label: "Documentation",
          position: "left",
        },
        { to: "blog", label: "Updates", position: "left" },
        {
          href: "https://github.com/cozie-app/cozie-apple",
          label: "GitHub",
          position: "right",
        },
        {
          href: "https://cozie.app",
          label: "Cozie Fitbit",
          position: "right",
        },
      ],
    },
    footer: {
      style: "light",
      links: [
        {
          title: "Documentation",
          items: [
            {
              label: "Introduction", 
              to: "docs/",
            },
          ],
        },
        {
          title: "Community",
          items: [
            {
              label: "BUDS Lab",
              href: "https://www.budslab.org",
            },
            {
              label: "SinBerBEST",
              href: "https://sinberbest.berkeley.edu",
            },
            {
              label: "Twitter",
              href: "https://twitter.com/FedericoTartar1",
            }
          ],
        },
        {
          title: "More",
          items: [
            {
              label: "Updates",
              to: "blog",
            },
            {
              label: "GitHub",
              href: "https://github.com/FedericoTartarini",
            },
            {
              label: "Privacy Policy",
              to: "docs/privacyPolicy",
            },
            {
              label: "Support",
              to: "docs/support",
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Cozie, BEARS and BUDS Lab. Built with Docusaurus.`,
    },
  },
  presets: [
    [
      "@docusaurus/preset-classic",
      {
        docs: {
          // It is recommended to set document id as docs home page (`docs/` path).
          // homePageId: "introduction",
          sidebarPath: require.resolve("./sidebars.js"),
          // Please change this to your repo.
          editUrl:
            "https://github.com/FedericoTartarini/cozie-apple/tree/master/my-website",
        },
        blog: {
          showReadingTime: true,
          // Please change this to your repo.
          editUrl:
            "https://github.com/FedericoTartarini/cozie-apple/tree/master/my-website/blog",
        },
        theme: {
          customCss: require.resolve("./src/css/custom.css"),
        },
        gtag: {
          trackingID: 'G-WC21KB6YKB',
          anonymizeIP: true,
        },
      },
    ],
  ],
};
