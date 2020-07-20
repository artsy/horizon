import consumer from "./consumer"

document.addEventListener("DOMContentLoaded", () => {
  const organization_id_input = document.querySelector(
    "#organization_subscription_identifier",
  ) as HTMLInputElement

  consumer.subscriptions.create(
    {
      channel: "ProjectChannel",
      organization_id: organization_id_input.value,
    },
    {
      connected() {
        // Called when the subscription is ready for use on the server
      },
      disconnected() {
        // Called when the subscription has been terminated by the server
      },
      received(data) {
        // Called when there's incoming data on the websocket for this channel
        if (data.newSnapshots || data.updatedBlocks) {
          location.reload()
        }
      },
    },
  )
})
