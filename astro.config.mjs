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
        { slug: '00a-preface' },
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
            { slug: '07-novel-pathogenic-mechanisms' },
            { slug: '08-environmental-triggers' },
            { slug: '09-drug-induced-psoriasis' },
          ],
        },
        {
          label: 'Part III: Clinical Practice',
          items: [
            { slug: '10-clinical-presentation' },
            { slug: '11-difficult-to-treat-sites' },
            { slug: '12-diagnostic-testing' },
            { slug: '13-biomarkers-precision-medicine' },
            { slug: '14-comorbidities' },
            { slug: '15-psoriatic-arthritis' },
          ],
        },
        {
          label: 'Part IV: Impact & Wellbeing',
          items: [
            { slug: '16-psychological-burden' },
            { slug: '17-sleep-sexual-health' },
            { slug: '18-pain-and-itch' },
          ],
        },
        {
          label: 'Part V: Living with Psoriasis',
          items: [
            { slug: '19-lifestyle-diet' },
            { slug: '20-daily-management' },
            { slug: '21-special-populations' },
            { slug: '22-remission' },
          ],
        },
        {
          label: 'Part VI: Treatment',
          items: [
            { slug: '23-topical-treatments' },
            { slug: '24-therapeutic-landscape' },
            { slug: '25-nhs-pathway' },
            { slug: '26-traditional-medicine' },
          ],
        },
        {
          label: 'Part VII: Research & Future',
          items: [
            { slug: '27-landmark-studies' },
            { slug: '28-emerging-research' },
            { slug: '29-digital-health' },
            { slug: '30-vaccination-and-covid19' },
          ],
        },
        { slug: '31-conclusion' },
        {
          label: 'Appendices',
          items: [
            { slug: 'a1-registries' },
            { slug: 'a2-patient-resources' },
            { slug: 'a3-major-books' },
            { slug: 'a4-glossary' },
            { slug: 'a5-references' },
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
