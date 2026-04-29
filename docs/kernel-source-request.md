# Requesting kernel source from Tripltek

The Linux kernel is licensed under GPL v2. Any company that ships a product running a Linux kernel — including every Android device manufacturer — is **legally required** to make the kernel source code available to anyone who asks for the corresponding device.

Tripltek ships Linux kernels in every device. As of this writing, no public Tripltek kernel source repository has been located. This document is a template and a record of who has asked.

---

## Why this matters

Without kernel source, custom ROM work is limited to:

- GSI flashing (works only if Treble is fully implemented and vendor blobs are compatible)
- Reverse engineering (slow, error-prone, fragile)

With kernel source, the door opens to:

- Proper TWRP / OrangeFox port
- A real LineageOS device tree
- Security patches the OEM never shipped
- Performance and battery tuning that respects display thermal limits

---

## How to ask

The polite, legally clean version. Do not threaten, do not invoke lawyers, do not be aggressive on the first contact. Most companies comply quickly when asked plainly.

### Email template

```
Subject: GPL kernel source request for Tripltek [model]

Hello,

I own a Tripltek [model name], serial [serial number],
software build [ro.build.fingerprint from About page].

The Linux kernel running on this device is licensed under GNU
General Public License v2. Section 3 of GPL v2 obligates
distributors to make the corresponding source code available
to recipients of the binary.

I am requesting the corresponding kernel source for the
software version on my device. A public Git repository, a
download link, or a tarball sent to this email address would
all be acceptable formats.

Thank you for your time.

[Your name]
```

Send to:
- Tripltek's general support contact
- Any engineering or developer contact you can find on their site

---

## Responses (community log)

If you've asked Tripltek for kernel source, please open a PR adding to this section so we don't all duplicate effort.

| Date | Asker | Device | Response | Notes |
|------|-------|--------|----------|-------|
| _none yet — be the first_ | | | | |

---

## If they refuse or stall

GPL enforcement organizations exist for exactly this case. They are professional, established, and will handle escalation properly:

- [Software Freedom Conservancy](https://sfconservancy.org/) — handles GPL compliance for many Linux subsystems
- [gpl-violations.org](https://gpl-violations.org/) — historical archive and contacts

**Do not try to escalate yourself.** A polite first ask, a polite second ask, and then handing it to a real compliance organization is the correct sequence. Anything more aggressive harms the community more than it helps.
