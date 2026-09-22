import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Zélum'Rai Studio",
  description: "Recording, mixing, mastering, beats, bookings and artist projects."
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return <html lang="fr"><body>{children}</body></html>;
}