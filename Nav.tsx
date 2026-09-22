import Link from "next/link";

export default function Nav() {
  return <nav className="nav"><div className="container navin">
    <Link href="/" className="logo">Zélum'Rai <span>Studio</span></Link>
    <div className="links">
      <Link href="/#services">Services</Link>
      <Link href="/music">Musique</Link>
      <Link href="/book">Book</Link>
      <Link href="/dashboard">Dashboard</Link>
    </div>
    <Link className="btn" href="/book">Book a Session</Link>
  </div></nav>;
}