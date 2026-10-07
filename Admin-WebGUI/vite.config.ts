import adapter from '@sveltejs/adapter-auto';
import { sveltekit } from '@sveltejs/kit/vite';
import { dirname } from 'node:path/win32';
import { fileURLToPath } from 'node:url';
import { sveltePreprocess } from 'svelte-preprocess'
import { defineConfig } from 'vite';

const filePath = dirname(fileURLToPath(import.meta.url))
const stylesPath = `${filePath}/src/styles`

export default defineConfig({
	plugins: [
		sveltekit({
    		adapter: adapter(),
			compilerOptions: {
				runes: ({ filename }) =>
					filename.split(/[/\\]/).includes('node_modules') ? undefined : true
			},

            preprocess: sveltePreprocess({
                scss: {
                    prependData: `@use '${stylesPath}/vars' as *;`
                },
			}),
		})
	]
});
