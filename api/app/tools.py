from .rag import call_llm

async def full_read_summarize(section_texts: list[str], goal: str) -> str:
    """Map-reduce style summarization over many chunks: summarize then synthesize."""
    if not section_texts:
        return "No content available to read."
    # map
    partials = []
    for chunk in section_texts:
        partials.append(
            await call_llm(
                f"Summarize this for the goal: {goal}. Keep key points & page refs if present.",
                [chunk],
            )
        )
    # reduce
    final = await call_llm(
        f"Synthesize these partial summaries into one concise answer for the goal: {goal}. Cite as [title p.X].",
        partials,
    )
    return final
