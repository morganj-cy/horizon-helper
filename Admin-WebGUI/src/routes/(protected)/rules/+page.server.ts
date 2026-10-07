import type { PageLoad } from './$types';
import { API_BASE_URL } from "$app/env/private"

export const load: PageLoad = async ({ fetch, params }) => {
    const res = await fetch(`${API_BASE_URL}/rules`)
    const json = await res.json();

    return { json }
}
