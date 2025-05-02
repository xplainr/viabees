# Cloudflare Workers - Preview URLs

These are development-stage `.workers.dev` preview endpoints used during staging and integration testing.

## Workers Deployment Targets

| Environment | Worker Name          | Preview URL                                        |
| ----------- | -------------------- | -------------------------------------------------- |
| Dev         | viabees-worker-dev   | https://viabees-worker-dev.infra-2d4.workers.dev   |
| Stage       | viabees-worker-stage | https://viabees-worker-stage.infra-2d4.workers.dev |
| Prod        | viabees-worker-prod  | https://viabees-worker-prod.infra-2d4.workers.dev  |

---

## Test Endpoints

### /api/share

Method: `POST`  
Example Payload:

```json
{
  "sharer_id": "example-sharer",
  "campaign_id": "example-campaign"
}
```
