# Zélum'Rai Studio V4

V4 is a Vercel-ready Next.js + Supabase + Stripe foundation.

## What's new
- Public music library
- Artist dashboard
- Booking requests
- Admin booking confirmation/cancellation
- Stripe Checkout API
- Stripe success/cancel pages
- Stripe webhook endpoint
- Supabase profiles, tracks, bookings and payments schema
- Responsive studio UI

## Setup

### 1. Supabase
Create a Supabase project and run `supabase/schema.sql` in SQL Editor.

Create a Storage bucket named `music` and make it Public for this V4 music library.

Configure Storage policies so:
- public users can read objects in `music`
- authenticated users can upload only under their own folder: `auth.uid()/...`

Create an account in `/auth`, then promote it to admin:
`update public.profiles set role='admin' where id='YOUR-USER-UUID';`

### 2. Local environment
Copy `.env.example` to `.env.local` and fill:
- NEXT_PUBLIC_SUPABASE_URL
- NEXT_PUBLIC_SUPABASE_ANON_KEY
- STRIPE_SECRET_KEY
- NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
- STRIPE_WEBHOOK_SECRET
- NEXT_PUBLIC_SITE_URL

Then:
`npm install`
`npm run dev`

### 3. Stripe
Create a Stripe account and use Test mode first.

The app creates Checkout Sessions at:
`POST /api/checkout`

Example request body:
`{"amount":5000,"description":"Recording session deposit"}`

`amount` is in cents, so 5000 = $50.00 USD.

Configure your Stripe webhook endpoint:
`https://YOUR-DOMAIN.com/api/stripe/webhook`

Subscribe to:
`checkout.session.completed`

Put the webhook signing secret into `STRIPE_WEBHOOK_SECRET`.

### 4. Vercel
Push this project to GitHub, import it into Vercel, and add all variables from `.env.example` in Vercel Project Settings > Environment Variables.

Set:
`NEXT_PUBLIC_SITE_URL=https://YOUR-DOMAIN.com`

Then deploy.

## Production notes
- The V4 music bucket is public because the public Music Library needs direct playback.
- For unreleased masters and private client files, use a separate private Storage bucket with signed URLs.
- The Stripe checkout API is real, but the current dashboard button is intentionally a foundation. V5 can connect payments directly to individual bookings and persist completed Stripe sessions in `payments`.
- Add rate limiting, stronger Storage policies, email notifications and server-side booking availability checks before public launch.
