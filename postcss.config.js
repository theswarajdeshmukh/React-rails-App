module.exports = {
  plugins: [
    require("postcss-import"),
    require("postcss-flexbugs-fixes"),
    require("postcss-preset-env")({
      autoprefixer: {
        flexbox: "no-2009",
      },
      stage: 3,
    }),
    require("tailwindcss")("./tailwind.config.js"),
    require("autoprefixer"),
  ],
};

// In simple terms postcss or post processing our CSS, takes our existing CSS and extends it,
// as opposed to preprocessors which use functions and variables to help write our CSS in a much more efficient,
// manageable way.
