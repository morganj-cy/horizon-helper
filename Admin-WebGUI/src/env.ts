import { defineEnvVars } from "@sveltejs/kit/env"

export const variables = defineEnvVars({
    API_BASE_URL: {
        description: "The base URL for the Horizon Helper API"
    }
})
