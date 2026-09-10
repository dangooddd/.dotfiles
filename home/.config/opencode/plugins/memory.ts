import { homedir } from "node:os"

export default {
  id: "memory",

  async setup(ctx) {
    let starting = false

    await ctx.session.hook("prompt", async (event) => {
      if (starting || event.metadata?.memory) return
      starting = true

      void (async () => {
        const day = new Date().toDateString()
        if ((await ctx.storage.get("day")) === day) return
        const source = await ctx.session.get({ sessionID: event.sessionID })

        const session = await ctx.session.create({
          title: "Memory: daily consolidation",
          agent: "memory",
          model: source.model,
          location: { directory: homedir() },
        })

        await ctx.session.prompt({
          sessionID: session.id,
          metadata: { memory: true },
          text: "Perform daily memory maintenance.",
        })
        await ctx.storage.set("day", day)
      })()
        .catch((error) => console.error("[memory]", error))
        .finally(() => {
          starting = false
        })
    })
  },
}
