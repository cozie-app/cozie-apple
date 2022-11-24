import React from "react";
import clsx from "clsx";
import Layout from "@theme/Layout";
import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import useBaseUrl from "@docusaurus/useBaseUrl";
import styles from "./styles.module.css";

const features = [
  {
    title: <>Free and Easy to Use</>,
    imageUrl: "img/undraw_watch_application.svg",
    description: (
      <>
        Building occupants can complete a right-here-right-now survey directly
        from their Apple watch. Without the need of having to open an app on
        their Phone or a survey link.
      </>
    ),
  },
  {
    title: <>Open Source</>,
    imageUrl: "img/undraw_dev_productivity_umsq.svg",
    description: (
      <>
        Cozie is an Open Source project and together with{" "}
        <a href={"https://cozie.app"}>Cozie Fitbit</a>, allows researchers to
        focus on the data collection. We have taken care of all the programming
        for you!
      </>
    ),
  },
  {
    title: <>Powered by Apple ResearchKit</>,
    imageUrl: "img/undraw_drag_5i9w.svg",
    description: (
      <>
        Cozie iOS app uses{" "}
        <a href={"https://www.researchandcare.org/researchkit/"}>
          Apple's Research Kit
        </a>
        . A software framework for Apple apps that let researchers gather robust
        and meaningful data.
      </>
    ),
  },
];

function Feature({ imageUrl, title, description }) {
  const imgUrl = useBaseUrl(imageUrl);
  return (
    <div
      className={clsx(
        "avatar avatar--vertical col col--4 text--center",
        styles.features
      )}
    >
      {imgUrl && (
        <div className="text--center">
          <img className={styles.featureImage} src={imgUrl} alt={title} />
        </div>
      )}
      <h3>{title}</h3>
      <p>{description}</p>
    </div>
  );
}

const contributors = [
  {
    name: <>Federico Tartarini</>,
    imageUrl: "img/federico.jpg",
    role: <>Lead developer</>,
    profession: <>Postdoctoral scholar at SinBerBEST</>,
    link: "https://federicotartarini.github.io",
  },
  {
    name: <>Clayton Miller</>,
    imageUrl: "img/clayton.png",
    role: <>Project coordinator and supervisor</>,
    profession: <>Assistant Professor at NUS</>,
    link: "https://www.linkedin.com/in/stefanoschiavon/",
  },
  {
    name: <>Stefano Schiavon</>,
    imageUrl: "img/stefano.jpeg",
    role: <>Project coordinator and supervisor</>,
    profession: <>Associate Professor at UC Berkeley</>,
    link: "https://www.linkedin.com/in/claytonmiller/",
  },
  {
    name: <>Mario Frei</>,
    imageUrl: "img/mario.jpeg",
    role: <>Developer</>,
    profession: <>Research Fellow at NUS</>,
    link: "https://sg.linkedin.com/in/mario-frei",
  },
];

function Contributor({ imageUrl, name, profession, role, link }) {
  const imgUrl = useBaseUrl(imageUrl);
  return (
    <div
      className={clsx(
        "avatar avatar--vertical col col--3 text--center",
        styles.features
      )}
    >
      <img
        className="avatar__photo avatar__photo--xl"
        src={imgUrl}
        alt={name}
      />
      <a className="avatar__intro" href={link}>
        <h4 className="avatar__name">{name}</h4>
        <small className="avatar__subtitle">{profession}</small>
        <small className="avatar__subtitle">{role}</small>
      </a>
    </div>
  );
}

function Home() {
  const context = useDocusaurusContext();
  const { siteConfig = {} } = context;
  return (
    <Layout
      title={`${siteConfig.title}`}
      description="Cozie - An iOS application for indoor environmental quality satisfaction and physiological data collection."
    >
      <header className={clsx("hero hero--primary", styles.heroBanner)}>
        <div className="container">
          <div className="row">
            <div className={clsx("col", styles.profileImgContainer)}>
              <img
                alt="cozie main question"
                className={styles.mainImage}
                src={useBaseUrl('img/main face.png')}  width="500"
              />
            </div>
            <div className={clsx("col", styles.profileHeroContainer)}>
              <h1 className="hero__title">{siteConfig.title}</h1>
              <p className="hero__subtitle">{siteConfig.tagline}</p>
              
              <Link
                className={clsx(
                  "button button--outline button--active button--secondary button--lg margin--sm"
                )}
                to={useBaseUrl("blog/")}
              >
              Latest version
              
              </Link>
              <a
                className={clsx(
                  "button button--outline button--active button--secondary button--lg margin--sm"
                )}
                href={"mailto:cozie.app@gmail.com"}
              >
                Contact us
           
              </a>
            </div>
          </div>
        </div>
      </header>
      <main>
        {features && features.length > 0 && (
          <section className={styles.features}>
            <div className="container">
              <div className="row">
                {features.map((props, idx) => (
                  <Feature key={idx} {...props} />
                ))}
              </div>
            </div>
          </section>
        )}
        <hr />
        <section className={styles.features}>
          <div className="container">
            <div className="row">
              <div className={clsx("col col--3")}>
                <img
                  alt="cozie main question"
                  className={styles.mainImage}
                  src={"img/main face.png"}
                />
              </div>
              <div className={clsx("col col--9")}>
                <h1 className="hero__title">Taylor your survey</h1>
                <p className="hero__subtitle">
                  Choose which questions to show to the study participants
                </p>
                <img
                  alt="Cozie flow of questions"
                  src={"img/sequence cozie apple.png"}
                />
              </div>
            </div>
          </div>
        </section>
        <hr />
        {contributors && contributors.length > 0 && (
          <section className={styles.features}>
            <div className="container">
              <h1>Developed and designed by:</h1>
              <div className="row">
                {contributors.map((props, idx) => (
                  <Contributor key={idx} {...props} />
                ))}
              </div>
            </div>
          </section>
        )}
      </main>
    </Layout>
  );
}

export default Home;
