import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Zig Functools",
  description: "Documentation for the zig functools library.",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Getting Started', link: '/getting-started' }
    ],

    sidebar: [
      {
        text: 'Examples',
        items: [
          { text: 'Getting Started', link: '/getting-started' },
          { text: 'Map', link: '/map' },
          { text: 'Reduce', link: '/reduce' },
          { text: 'Filter', link: '/filter' },
          { text: 'Some and Every', link: '/some-and-every' },
          { text: 'Threading', link: '/threading' },
          { text: 'API', link: '/api' }
        ]
      }
    ],
    aside: true,
    socialLinks: [
      { icon: 'github', link: 'https://github.com/ali-shahwali/zig-functools' }
    ]
  },
  base: "/zig-functools/"
})
