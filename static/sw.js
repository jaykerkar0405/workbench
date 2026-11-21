const VERSION = 'workbench-v1';
const PAGE_CACHE = `${VERSION}-pages`;
const ASSET_CACHE = `${VERSION}-assets`;
const IMMUTABLE_CACHE = `${VERSION}-immutable`;

const ALL_CACHES = [IMMUTABLE_CACHE, ASSET_CACHE, PAGE_CACHE];

self.addEventListener('install', (event) => {
    self.skipWaiting();
    event.waitUntil(caches.open(PAGE_CACHE).then((cache) => cache.addAll(['/', '/projects', '/hackathons'])));
});

self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches
            .keys()
            .then((keys) =>
                Promise.all(
                    keys.filter((key) => !ALL_CACHES.includes(key)).map((key) => caches.delete(key))
                )
            )
            .then(() => self.clients.claim())
    );
});

self.addEventListener('fetch', (event) => {
    const { request } = event;
    const url = new URL(request.url);

    if (request.method !== 'GET' || url.origin !== self.location.origin) return;

    if (url.pathname.startsWith('/_app/immutable/')) {
        event.respondWith(
            caches.match(request).then(
                (cached) =>
                    cached ||
                    fetch(request).then((response) => {
                        if (response.ok) {
                            const clone = response.clone();
                            caches.open(IMMUTABLE_CACHE).then((cache) => cache.put(request, clone));
                        }
                        return response;
                    })
            )
        );
        return;
    }

    if (url.pathname.match(/\.(png|jpg|jpeg|webp|svg|gif|ico|woff2?|ttf|otf)$/i)) {
        event.respondWith(
            caches.match(request).then((cached) => {
                const network = fetch(request).then((response) => {
                    if (response.ok) {
                        const clone = response.clone();
                        caches.open(ASSET_CACHE).then((cache) => cache.put(request, clone));
                    }
                    return response;
                });
                return cached || network;
            })
        );
        return;
    }

    if (request.mode === 'navigate') {
        event.respondWith(
            fetch(request)
                .then((response) => {
                    if (response.ok) {
                        const clone = response.clone();
                        caches.open(PAGE_CACHE).then((cache) => cache.put(request, clone));
                    }
                    return response;
                })
                .catch(() => caches.match(request))
        );
        return;
    }

    event.respondWith(
        caches.match(request).then((cached) => {
            const network = fetch(request).then((response) => {
                if (response.ok) {
                    const clone = response.clone();
                    caches.open(ASSET_CACHE).then((cache) => cache.put(request, clone));
                }
                return response;
            });
            return cached || network;
        })
    );
});
