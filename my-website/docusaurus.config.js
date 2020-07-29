module.exports = {
  title: "Cozie Apple",
  tagline: "Cozie Apple - an iOS app for human comfort data collection.",
  url: "https://cozie-apple.netlify.app",
  baseUrl: "/",
  favicon: "img/favicon.ico",
  organizationName: "FedericoTartarini", // Usually your GitHub org/user name.
  projectName: "cozie-apple", // Usually your repo name.
  themeConfig: {
    navbar: {
      title: "Cozie Apple",
      logo: {
        alt: "Cozie Apple Logo",
        src: "img/logo.png",
      },
      links: [
        {
          to: "docs/",
          activeBasePath: "docs",
          label: "Docs",
          position: "left",
        },
        { to: "blog", label: "Blog", position: "left" },
        {
          href: "https://github.com/FedericoTartarini",
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
          title: "Docs",
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
            },
          ],
        },
        {
          title: "More",
          items: [
            {
              label: "Blog",
              to: "blog",
            },
            {
              label: "GitHub",
              href: "https://github.com/FedericoTartarini",
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Cozie Apple, BEARS and BUDS Lab. Built with Docusaurus.`,
    },
  },
  presets: [
    [
      "@docusaurus/preset-classic",
      {
        docs: {
          // It is recommended to set document id as docs home page (`docs/` path).
          homePageId: "introduction",
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
      },
    ],
  ],
};
