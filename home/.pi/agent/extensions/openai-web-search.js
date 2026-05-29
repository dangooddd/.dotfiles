const SOURCES_INCLUDE = "web_search_call.action.sources";
const WEB_SEARCH_BY_API = {
	"openai-responses": { type: "web_search" },
	"openai-codex-responses": { type: "web_search", external_web_access: false },
};

function isNativeWebSearch(tool) {
	return tool.type === "web_search" || tool.type === "web_search_preview";
}

export default function (pi) {
	pi.on("before_provider_request", (event, ctx) => {
		const webSearchTool = WEB_SEARCH_BY_API[ctx.model?.api];
		if (!webSearchTool) return;

		const payload = event.payload;
		const tools = Array.isArray(payload.tools)
			? payload.tools.filter((tool) => !(tool.name === "web_search" && !isNativeWebSearch(tool)))
			: [];
		if (!tools.some(isNativeWebSearch)) tools.push(webSearchTool);

		const include = Array.isArray(payload.include) ? payload.include.filter((value) => typeof value === "string") : [];

		return {
			...payload,
			tools,
			include: include.includes(SOURCES_INCLUDE) ? include : [...include, SOURCES_INCLUDE],
		};
	});
}
