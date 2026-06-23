import warnings
import os
from typing import TypedDict, Annotated
from langgraph.graph import StateGraph, START, END, add_messages
from langgraph.prebuilt import ToolNode, tools_condition
from langchain_core.runnables import RunnableConfig
from langchain.messages import AnyMessage, SystemMessage, HumanMessage
from Agent.agent_tools import *
HF_API_KEY=os.getenv("HF_API_KEY")
warnings.filterwarnings("ignore", message="The default value of `allowed_objects`")
from langchain_huggingface import ChatHuggingFace, HuggingFaceEndpoint

llm = HuggingFaceEndpoint(
    repo_id="Qwen/Qwen2.5-7B-Instruct",
    huggingfacehub_api_token=HF_API_KEY,
    task="text-generation"
)



model = ChatHuggingFace(llm=llm)
model_with_tools = model.bind_tools(tools)

def assistant(state):
    query = state["messages"][-1].content
    messages = state["messages"]

    SYSTEM_PROMPT = f"""
ROLE:
You are an intelligent automotive and AI assistant.

USER QUERY:
{query}

INSTRUCTIONS:
- Keep your response short, clean, well-formatted, and straight to the point. Avoid long paragraphs.
- Briefly and naturally mention the source or tool used (e.g., "Based on a quick database lookup..." or "According to the mechanical diagnostic tool..."). Do not overexplain it.
- Never describe your internal reasoning, thinking process, or workflow steps.
- Provide a clear, natural, and highly professional answer.
- Focus entirely on solving the user's problem efficiently.
"""

    response = model_with_tools.invoke(
        [SystemMessage(content=SYSTEM_PROMPT)] + messages
    )
    return {"messages": [response]}

class AgentState(TypedDict):
    messages: Annotated[list[AnyMessage], add_messages]

graph = StateGraph(AgentState)
graph.add_node("assistant", assistant)
graph.add_node("tools", ToolNode(tools))

graph.add_edge(START, "assistant")
graph.add_conditional_edges(
    "assistant",
    tools_condition,
    {"tools": "tools", "__end__": END}
)
graph.add_edge("tools", "assistant")

Agent = graph.compile()

async def generate(user_query):
    full_text = ""

    async for message, metadata in Agent.astream(
        {"messages": [HumanMessage(content=user_query)]},
        stream_mode="messages"
    ):
        node = metadata.get("langgraph_node")

        # ✅ Tool selected
        if hasattr(message, "tool_calls") and message.tool_calls:
            for tool in message.tool_calls:
                print(tool["name"])

        # ✅ Tool result
        if node == "tools":
            content = getattr(message, "content", None)
            if content:
                print(content) 

        # ✅ Assistant - MOT PAR MOT
        elif node == "assistant":
            content = getattr(message, "content", None)
            
            if isinstance(content, str):
                text_content = content
            elif isinstance(content, list):
                text_content = ""
                for block in content:
                    if isinstance(block, dict) and block.get("type") == "text":
                        text_content += block.get("text", "")
                    elif isinstance(block, str):
                        text_content += block
            else:
                continue

            if not text_content.strip():
                continue

            # ✅ Découpe en mots et envoie mot par mot
            full_text += text_content
            words = full_text.split()
            
            for word in words:
                yield f"data: {word} \n\n"

