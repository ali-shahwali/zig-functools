import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Zig Functools",
  description: "Documentation for the zig functools library.",
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Getting Started', link: '/guide/getting-started' }
    ],

    sidebar: [
      {
        text: 'Guide',
        items: [
          { text: 'Getting Started', link: '/guide/getting-started' },
          { text: 'Map', link: '/guide/map' },
          { text: 'Reduce', link: '/guide/reduce' },
          { text: 'Filter', link: '/guide/filter' },
          { text: 'Some and Every', link: '/guide/some-and-every' },
          { text: 'Threading', link: '/guide/threading' },
          { text: 'Sequence', link: '/guide/sequence' }
        ]
      },
      {
        text: "API",
        items: [
          { text: "Core", link: '/api/core' },
          { text: "Thread", link: '/api/thread' },
          { text: "Utilities", link: '/api/utilities' },
        ],
      }
    ],
    aside: true,
    socialLinks: [
      { icon: 'github', link: 'https://github.com/ali-shahwali/zig-functools' }
    ]
  },
  base: "/zig-functools/"
})
