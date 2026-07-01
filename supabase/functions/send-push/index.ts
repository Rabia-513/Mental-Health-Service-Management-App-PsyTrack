import { serve } from "https://deno.land/std/http/server.ts";

serve(async (req) => {

  const { externalId, title, body } = await req.json();

  const ONESIGNAL_APP_ID = "YOUR_APP_ID";
  const ONESIGNAL_API_KEY = "YOUR_REST_API_KEY";

  const response = await fetch("https://api.onesignal.com/notifications", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Key ${ONESIGNAL_API_KEY}`
    },
    body: JSON.stringify({
      app_id: ONESIGNAL_APP_ID,
      include_aliases: {
        external_id: [externalId]
      },
      target_channel: "push",
      headings: { en: title },
      contents: { en: body }
    })
  });

  return new Response(await response.text(), { status: 200 });
});