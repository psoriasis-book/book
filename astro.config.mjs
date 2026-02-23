import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
  site: 'https://psoriasis.fyi',
  integrations: [
    starlight({
      title: 'Psoriasis: A Comprehensive Review',
      description:
        'A meta-analysis of pathogenesis, immunology, genetics, and therapeutics',
      social: {
        github: 'https://github.com/psoriasis-book/book',
      },
      sidebar: [
        { slug: '00-abstract' },
        {
          label: 'Part I: Foundation & Context',
          items: [
            { slug: '01-introduction' },
            { slug: '02-history' },
            { slug: '03-epidemiology' },
          ],
        },
        {
          label: 'Part II: Understanding the Disease',
          items: [
            { slug: '04-immune-system' },
            { slug: '05-genetics' },
            { slug: '06-immunopathogenesis' },
            { slug: '07-environmental-triggers' },
          ],
        },
        {
          label: 'Part III: Clinical Practice',
          items: [
            { slug: '08-clinical-presentation' },
            { slug: '09-diagnostic-testing' },
            { slug: '10-comorbidities' },
            { slug: '11-psychological-burden' },
          ],
        },
        {
          label: 'Part IV: Living with Psoriasis',
          items: [
            { slug: '12-lifestyle-diet' },
            { slug: '13-daily-management' },
            { slug: '14-special-populations' },
            { slug: '15-remission' },
          ],
        },
        {
          label: 'Part V: Treatment',
          items: [
            { slug: '16-therapeutic-landscape' },
            { slug: '17-nhs-pathway' },
            { slug: '18-traditional-medicine' },
          ],
        },
        {
          label: 'Part VI: Research & Future',
          items: [
            { slug: '19-landmark-studies' },
            { slug: '20-emerging-research' },
            { slug: '21-covid19' },
          ],
        },
        {
          label: 'Appendices',
          items: [
            { slug: '22-registries' },
            { slug: '23-major-books' },
            { slug: '24-glossary' },
            { slug: '25-conclusion' },
            { slug: '26-references' },
          ],
        },
      ],
      editLink: {
        baseUrl: 'https://github.com/psoriasis-book/book/edit/main/',
      },
      lastUpdated: true,
      pagination: true,
      tableOfContents: { minHeadingLevel: 2, maxHeadingLevel: 3 },
    }),
  ],
});
