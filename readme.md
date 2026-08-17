# Docker "running as root" — what actually goes wrong

A hands-on demo showing why building a container image that runs as **root**
(the default when you don't set `USER`) is a security risk, and what an attacker
or a compromised app can do with it: **read your data, tamper with it, and copy
it out.**

## The actual issue in one paragraph

Inside a container, `root` is UID 0. On the host kernel, `root` is also UID 0.
By default Docker does **not** remap these — user namespaces are off. So a
process running as root inside the container is, to the kernel and to any files
you bind-mount from the host, the *same* root. That means: (1) anything mounted
into the container can be read, modified, and deleted with root's power,
regardless of who owns it; (2) if your app has a vulnerability, the attacker who
exploits it becomes root instead of an unprivileged user, which is the
difference between a contained incident and a full host compromise; and (3) if
the Docker socket or extra capabilities are ever exposed to that root process,
it can trivially take over the whole machine. Running as a non-root user removes
almost all of this blast radius for free.

## What the demo shows

`run-demo.sh` builds two images from the **same app**, differing only by one
line in the Dockerfile:

- `vulnerable/Dockerfile` — no `USER`, so it runs as **root**.
- `secure/Dockerfile` — creates `appuser` and adds `USER appuser`, so it runs
  **non-root**.

It then mounts a folder of fake secrets (`customer-data.csv`, `app.env`) into
each container and lets the app try to read, modify, and exfiltrate them. You
watch the root container succeed at all three and see the difference when the
non-root container runs.

`privilege-contrast.sh` (optional, needs `sudo`) is the sharpest proof: it
creates a file owned by **host root** with `600` permissions — something your
own user can't even read — and shows the non-root container is denied while the
root container reads and overwrites it.

## Run it

Requires Docker.

```bash
chmod +x run-demo.sh privilege-contrast.sh app.sh
./run-demo.sh
```

Then, for the sharper root-owned-file contrast:

```bash
./privilege-contrast.sh
```

Re-running is safe — `run-demo.sh` recreates the fake data each time and nothing
touches real system files.

## The fix (what to show at the end)

The entire fix is visible by diffing the two Dockerfiles. In every image you
build, add a non-root user and switch to it:

```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

Then reinforce it at runtime with defense in depth:

```bash
docker run \
  --user 1000:1000 \        # don't run as root even if the image forgot
  --read-only \             # filesystem is read-only
  --cap-drop ALL \          # drop all Linux capabilities
  --security-opt no-new-privileges \
  myimage
```

And two things to *never* do unless you fully mean it: don't mount
`/var/run/docker.sock` into a container (it's equivalent to root on the host),
and don't bind-mount sensitive host paths like `/`, `/etc`, or `~/.ssh` into a
root container.

## Talking points for the demo audience

- "Container root is host root" — the mount is the proof, not a slide.
- The vulnerable and secure images are byte-for-byte identical except `USER`.
- The non-root "permission denied" is exactly the damage you prevented.
- Root by default is why base images and tutorials quietly leave you exposed.
