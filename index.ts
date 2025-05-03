fetch("http://localhost:3000/embed", {
  method: "POST",
  body: JSON.stringify({ text: "Hello, world!" }),
  headers: {
    "Content-Type": "application/json",
  },
})
  .then((res) => res.text())
  .then((data) => {
    console.log(data);
  });
