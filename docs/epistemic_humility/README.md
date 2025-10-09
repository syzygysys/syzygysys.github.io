Abstract

The Epistemic Humility score is a mechanism for quantifying, communicating, and calibrating the epistemic confidence of AI agent outputs. Designed to solve the critical pain point of unqualified answers in generative AI systems, which erodes trust, increases cost through retries, and leads to operational brittleness. EH introduces a certainty score model, balancing precision with epistemic humility, and provides a standardized interface for reasoning transparency.

Motivation

The Epistemic Humility score (EHS) is gauged by the agentic at the time of a proposed action.  The scale is 0 - 1 with 0 = dead certain and 1 = clueless.
The EHS is included in the RAT envelope for proposed actions and determines, along with the criticality index, the autonomic level the agent is cleared to proceed with.  The goal is to establish trust over time by history of accurate EHS gauging and appropriate next step analysis.

Just as networking protocols require clear routing metrics to ensure stability and predictability, AI orchestration requires explicit measures of confidence. Current LLM agents frequently respond with high-entropy outputs without conveying how certain they are of correctness. This results in:

Poor human-in-the-loop (HITL) efficiency.

Overreliance on post-hoc evaluation (RAT, eval harnesses).

Difficulty routing tasks to the most reliable sub-agent.

ACE fills this gap by embedding certainty vectors into every response, enabling systematic trust calibration.
