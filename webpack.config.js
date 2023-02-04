const path = require('path')
const { merge } = require('webpack-merge')
const parts = require('./webpack.parts')
const { mode, analyze } = require('webpack-nano/argv')
const { DefinePlugin } = require('webpack');

const common = (compileType, puzzleName) => merge([
  { output: { path: path.resolve(process.cwd(), 'dist/' + puzzleName.charAt(0).toUpperCase() + puzzleName.substring(1) + '/' + compileType) } },
  { plugins: [
    new DefinePlugin({
      "process.env.compileType": JSON.stringify(compileType),
      "process.env.puzzleName": JSON.stringify(puzzleName),
      "DEPLOY_BASE_URL": "DEPLOY_BASE_URL_VAL" 
    })]
  },
  parts.page({ title: 'Test' }),
  parts.loadSvg(),
  parts.loadAssets(),
  parts.svelte(mode),
  parts.extractCSS({ loaders: [parts.postcss()] }),
  parts.cleanDist(),
  parts.useWebpackBar(),
  parts.useDotenv(),
  parts.useModuleFederation(mode, compileType, puzzleName)
])

const development = (compileType, puzzleName) => merge([
  { entry: ['./pzz-' + puzzleName +  '/' + compileType + '/index.ts', 'webpack-plugin-serve/client'] },
  { target: 'web' },
  parts.generateSourceMaps({ type: 'eval-source-map' }),
  parts.esbuild(),
  parts.devServer(compileType, puzzleName)
])

const production = (compileType, puzzleName) => merge([
    { entry: ['./pzz-' + puzzleName +  '/' + compileType + '/index.ts'] },
    { target: 'web' },
    parts.typescript(),
    analyze && parts.analyze()
  ].filter(Boolean)
)

module.exports = (env, args) => {
  if (!(["play", "edit"].includes(args.type))) {
    throw new Error(`Unknown type, ${args.type}`);
  }

  switch (args.mode) {
    case 'production':
      return merge(common(args.type, args.puzzle), production(args.type, args.puzzle), { mode: args.mode })
    case 'development':
      return merge(common(args.type, args.puzzle), development(args.type, args.puzzle), { mode: args.mode })
    default:
      throw new Error(`Unknown mode, ${args.mode}`);
  }
} 
