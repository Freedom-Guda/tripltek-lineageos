# Contributing

Thank you for being here. Even small contributions move this forward.

## What helps most, in order

1. **Device info dumps** from any Tripltek owner — see [docs/how-to-dump-device-info.md](docs/how-to-dump-device-info.md)
2. **GSI test reports** — see [docs/gsi-test-template.md](docs/gsi-test-template.md)
3. **Bootloader unlock walkthroughs** — replace the placeholder section in [docs/bootloader-unlock.md](docs/bootloader-unlock.md)
4. **Kernel source request log entries** — track who has asked Tripltek and what they got
5. **TWRP / device tree work** — the highest-skill, highest-impact contribution
6. **Forum links and references** — add to [community/threads.md](community/threads.md)

## Repository conventions

- One PR per logical change. A device info dump for the T7 Pro and a kernel request log entry are two PRs, not one.
- Keep device-specific content under `devices/<device>/`. Keep cross-device content under `docs/`.
- Sanitize personal info before posting (serials, IMEIs, MAC addresses, account names).
- No binary blobs or proprietary firmware in this repo. Link to upstream sources, don't mirror.
- Markdown files use ATX-style headings (`#`, `##`) and 80-ish-character lines, but don't fight your editor's wrap if the content reads well.

## Issues

Use the issue templates. If your situation doesn't fit one, open a blank issue and we'll figure it out.

## Code of conduct

Be helpful, be patient, assume the other person is also trying to make this work. If someone shares a brick log they're embarrassed about, thank them — that data is gold.

## What we won't accept

- Anything that includes leaked firmware, signed bootloader keys, or other material that could expose contributors to legal risk
- Aggressive escalation against Tripltek as a company. We want kernel source. We do not want a flame war.
- "Why isn't this done yet" issues without a contribution attached. The answer is always: nobody has had time.
