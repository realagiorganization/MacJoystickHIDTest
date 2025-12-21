const revealItems = Array.from(document.querySelectorAll("[data-reveal]"));

const reveal = (entries, observer) => {
  entries.forEach((entry) => {
    if (entry.isIntersecting) {
      entry.target.classList.add("visible");
      observer.unobserve(entry.target);
    }
  });
};

const observer = new IntersectionObserver(reveal, {
  threshold: 0.2,
});

revealItems.forEach((item, index) => {
  item.style.animationDelay = `${index * 90}ms`;
  observer.observe(item);
});
