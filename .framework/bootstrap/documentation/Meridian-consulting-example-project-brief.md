PROJECT BRIEF
Prepared by: Alex Chen
Date: 2026-03-06

Project Name
Meridian Consulting — Launch Landing Page

What I Want to Build
I need a single-page marketing website for my consulting practice, Meridian
Consulting. This will be the public-facing presence for the business and needs
to look professional and modern. The page should have sections for: a hero
introduction, a services overview, an about section, and a contact form that
routes inquiries to my email. I want it to feel clean, minimal, and credible —
think Linear.app or Stripe's marketing pages: clean typography, bold headings,
lots of whitespace.

Technology
I want to build this with AstroJS using Shadcn components for the UI. I expect
this means I'll need the React integration for Astro. Deploy to Cloudflare
Workers on my domain.

Domain
My domain meridianconsulting.com.au is already registered through Cloudflare.
I have a Cloudflare account set up and DNS control.

Environment
I work on a MacBook Pro M2, macOS Sonoma. I use VS Code. I have Node.js
installed but I don't know the exact version off the top of my head. I
normally use npm but I'm open to pnpm if it's better suited to this stack.

People
Alex Chen — project owner, decision-maker, and final approver. That's me.
No other stakeholders.

Scale
Small project. I'd like it done within a week. Just the single page — nothing
else for now.

Constraints
- The contact form must not require a dedicated backend. I want to use a
  third-party form handler — I'm thinking Formspree but I'm open to
  alternatives.
- The site must be fully static — no server-side rendering.
- Must score 90+ on Lighthouse Performance.
- Keep the dependency footprint minimal; avoid unnecessary packages.

Out of Scope (explicitly)
- CMS or any content management capability
- Blog or additional pages
- Analytics integration
- Any server-side logic beyond what Cloudflare Workers provides at the edge

What Success Looks Like
The site is live on meridianconsulting.com.au, passes 90+ Lighthouse
Performance, looks professional, the contact form works, and I can hand it off
to a developer friend later without it being a mess.
