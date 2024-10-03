### Front-end Setup
1. Install or update bun
    - version: 1.1.29
    `$ brew install bun` or `$ brew upgrade bun`

2. Install Vite
    ```bash
    $ bundle add vite_rails
    $ bundle exec vite install
    ```

3. Switch to Bun
    ```bash
    $ rm package-lock.json
    $ bun install
    ```

4. Add packages
    Install Vue, TypeScript, Tailwind, fontawesome and other typical JavaScript packages used with Vue.
    Update `package.json` as in below:
    ```json
    {
      "name": "tictactoe-ui",
      "private": true,
      "version": "0.0.0",
      "type": "module",
      "scripts": {
        "dev": "vite",
        "build": "vue-tsc && vite build",
        "preview": "vite preview"
      },
      "dependencies": {
        "@fortawesome/fontawesome-svg-core": "^6.6.0",
        "@fortawesome/free-brands-svg-icons": "^6.6.0",
        "@fortawesome/free-regular-svg-icons": "^6.6.0",
        "@fortawesome/free-solid-svg-icons": "^6.6.0",
        "@fortawesome/vue-fontawesome": "^3.0.8",
        "@vueuse/core": "^11.1.0",
        "pinia": "^2.2.4",
        "vue": "^3.5.8",
        "vue-router": "^4.4.5"
      },
      "devDependencies": {
        "@vitejs/plugin-vue": "^5.1.4",
        "autoprefixer": "^10.4.20",
        "postcss": "^8.4.47",
        "tailwindcss": "^3.4.12",
        "typescript": "^5.6.2",
        "vite": "^5.4.8",
        "vue-tsc": "^2.1.6"
      }
    }
    ```
    Then, install packages:
    ```bash
    $ bun install
    ```

5. Configure Vue plugin
    Update `vite.config.ts` as in below:
    ```typescript
    // vite.config.ts

    import { defineConfig } from 'vite'
    import RubyPlugin from 'vite-plugin-ruby'
    import vue from '@vitejs/plugin-vue'

    export default defineConfig({
      plugins: [
        RubyPlugin(),
        vue(),
      ],
    })
    ```

6. Create TypeScript configuration
    Create a vue project independently with TypeScript support. For example, `bun create vite`.
    Then, copy `tsconfig.json`, `tsconfig.node.js` and others (if exist) to a Rails app top directory.

    - `tsconfig.json`
    ```json
    {
   　　"compilerOptions": {
   　　　　"target": "ES2020",
        　"useDefineForClassFields": true,
        　"module": "ESNext",
        　"lib": ["ES2020", "DOM", "DOM.Iterable"],
        　"skipLibCheck": true,

        　/* Bundler mode */
        　"moduleResolution": "bundler",
        　"allowImportingTsExtensions": true,
        　"resolveJsonModule": true,
        　"isolatedModules": true,
        　"noEmit": true,
        　"jsx": "preserve",

        　/* Linting */
        　"strict": true,
        　"noUnusedLocals": true,
        　"noUnusedParameters": true,
        　"noFallthroughCasesInSwitch": true
   　　},
   　　"include": ["app/frontend/**/*.ts", "app/frontend/**/*.d.ts", "app/frontend/**/*.tsx", "app/frontend/**/*.vue"],
   　　"references": [{ "path": "./tsconfig.node.json" }]
    }
    ```

    - `tsconfig.node.json`
    ```json
    {
      "compilerOptions": {
        "composite": true,
        "skipLibCheck": true,
        "module": "ESNext",
        "moduleResolution": "bundler",
        "allowSyntheticDefaultImports": true
      },
      "include": ["vite.config.ts"]
    }
    ```

7. Setup starter command
    - `Procfile.dev`\
       Replace the content in `Profile.dev` with two lines below. For a front-end dev server, it uses definition in
       package.json.
    ```bash
    web: bin/rails s
    js: bun run dev
    ```
   - Install foreman
   ```bash
   $ bundle add foreman --group "development, test"
   ```
   - Create `bin/dev`
    ```bash
    #!/usr/bin/env sh

    # Default to port 3000 if not specified
    export PORT="${PORT:-3000}"

    bundle exec foreman start -f Procfile.dev "$@"
    ```
    Change the bin/dev permission to an executable one, for example, `chmod 755 bin/dev`.
    The backend and frontend servers start by `bin/dev` command.

8. Create a Vue app mount point\
    Create a controller and view to mount Vue app.
    ```bash
    $ rails g controller home index
    ```
