import { API_BASE_URL } from "$app/env/private"
import type { PageServerLoad } from "./$types";

export const load: PageServerLoad = async ({ fetch }) => {
    const res = await fetch(`${API_BASE_URL}/rules`)
    const json = await res.json();

    return { json }
}
