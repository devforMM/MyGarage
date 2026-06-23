from langchain_community.tools import DuckDuckGoSearchRun
from langchain_community.tools import Tool
from chunking.search_functions import retrieve_content

retriever_tool = Tool(
    name="GarageRetrieverTool",
    func=retrieve_content,
    description="""
ALWAYS use this tool FIRST before answering ANY question about cars or vehicles.
NEVER answer automotive questions from memory alone — always retrieve context first.

This tool searches a specialized garage and automotive repair knowledge base.

TRIGGER this tool for ANY of these topics:
- Engine problems (overheating, misfires, knocking, stalling, no start)
- Warning lights (check engine, ABS, oil pressure, battery, TPMS)
- Brakes (pads, rotors, calipers, brake fluid, ABS)
- Transmission (slipping, hard shifting, no reverse, fluid)
- Suspension & steering (vibration, pulling, noise, shocks, struts)
- Cooling system (radiator, thermostat, coolant leak, water pump)
- Electrical (battery, alternator, starter, fuses, wiring)
- Oil & fluids (leaks, consumption, type, change intervals)
- Fuel system (injectors, pump, pressure, economy)
- Exhaust (smoke color, catalytic converter, DPF, noise)
- Tires (pressure, wear, alignment, balancing)
- AC & heating (not cooling, not heating, refrigerant, compressor)
- Diagnostic codes (OBD2, fault codes, error codes)
- Maintenance schedules (oil change, timing belt, filters)
- Noise diagnosis (clicking, grinding, squealing, rattling)
- General garage & mechanic questions

Input: The complete user question as a string.

Output format:
{
    "content": "Relevant automotive knowledge and diagnostic context"
}

IMPORTANT:
- Always call this tool before generating any automotive answer
- Use the retrieved content as your primary knowledge source
- Combine retrieved context with your reasoning to give a complete answer
- If the tool returns empty content, answer from your general knowledge
"""
)


tools = [retriever_tool]