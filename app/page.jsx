import Image from "next/image";
import styles from "./page.module.css";

export default function Home() {
  // NEXT_PUBLIC_ で始まる環境変数を取得
  const appName = process.env.NEXT_PUBLIC_APP_NAME;

  return (
    <main className={styles.main}>
      {/* 環境変数を表示 */}
      <h1>Welcome to {appName || 'My Next App'}!</h1>

      {/* 以下、元々のコードは省略または適宜残す */}
      <div className={styles.description}>
        <p>
          Get started by editing aaaa bbbbbb ccccccccc
          <code className={styles.code}>app/page.jsx</code>
        </p>
        {/* ... */}
      </div>
    </main>
  );
}