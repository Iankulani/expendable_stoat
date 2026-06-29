# expendable_stoat

Expendable_Stoat is a modern cybersecurity command and orchestration platform designed to simplify security operations, cyber defense exercises, authorized penetration testing, security research, and cybersecurity education. The platform provides security professionals with a centralized environment for securely managing defensive tools, automation workflows, and col*laborative incident response across multiple communication platforms.

The tool integrates seamlessly with a wide array of messaging and collaboration platforms:

Discord: Leveraging webhooks and bot APIs, Expendable_Stoat can sit silently in a private server, awaiting commands. The tool parses JSON payloads sent as chat messages, allowing the operator to dispatch complex strings of code or retrieve screenshots and system logs directly within the chat interface. The aesthetic familiarity of Discord reduces suspicion during social engineering engagements, as the target may simply view the activity as standard bot interaction.

Slack: In the corporate environment, Slack is the lifeblood of communication. Expendable_Stoat utilizes Slack’s Real-Time Messaging (RTM) and Events API to create a persistent, stealthy connection. Operators can issue commands via slash commands or private messages, making the traffic indistinguishable from legitimate business communication. This makes it ideal for internal penetration tests where the adversary is assumed to have limited exfiltration paths.

iMessage (Apple Ecosystem): Recognizing the dominance of Apple products in executive suites, Expendable_Stoat includes a module for operating within the iMessage framework. This allows operators to control devices or relay information via Apple’s secure messaging protocol, often bypassing network-based intrusion detection systems (IDS) that struggle to decrypt Apple’s end-to-end encryption.

Telegram: Known for its speed and strong encryption, Telegram is a favorite for secure communication. Expendable_Stoat uses Telegram Bots to provide a low-latency, global C2 network. The bot can forward system information, handle multi-factor authentication prompts, and even download files directly from the target machine via the Telegram cloud, offering a high level of convenience and redundancy.

Web Application Interface: For those who prefer a traditional dashboard, the tool offers a rich, responsive web application. This interface provides a birds-eye view of all active agents, complete with geolocation tracking, network topology mapping, and real-time command output. The web UI allows for the creation of "Playbooks"—automated sequences of commands triggered by specific system states.

Social Engineering Toolset: The Human Firewall Test
While technical vulnerabilities are often patched quickly, the human element remains the most exploitable vector. Expendable_Stoat’s "Sociol Enginnerint Ool" (Social Engineering Toolkit) is a sophisticated suite designed to simulate the tactics of advanced persistent threats (APTs).

The social engineering module goes beyond basic phishing. It includes:

Credential Harvesting via Cloning: The tool can rapidly clone authentication portals for Office 365, Google Workspace, or custom corporate VPNs. When deployed via the communication channels, the clone sends the harvested credentials back to the operator via the encrypted C2 channel, bypassing traditional email filters by using legitimate platform links (e.g., a Discord embed pointing to a look-alike domain).

Pretexting Scripts: Expendable_Stoat generates dynamic pretexting scripts tailored to the target environment. By scraping public data (LinkedIn, corporate bios), the tool suggests the most effective psychological triggers (urgency, authority, or reciprocation) to integrate into a conversation.

Vishing and SMS Spoofing: Integrated with VoIP services, the tool allows operators to launch voice phishing (vishing) campaigns, spoofing the caller ID of internal helpdesks or senior executives. This module includes a text-to-speech synthesizer that adapts to the target's native language and corporate jargon.

MFA Fatigue Exploitation: Recognizing the rise of Multi-Factor Authentication (MFA), Expendable_Stoat automates MFA fatigue attacks. It sends repeated push notifications to the target’s mobile device via the messaging integration, hoping to trick the user into accepting the prompt out of annoyance or confusion.

Offensive Network Capabilities: The DDoS Module
No modern multi-tool is complete without the ability to test network resilience. The DDoS (Distributed Denial of Service) component of Expendable_Stoat allows security teams to simulate volumetric, application-layer, and protocol attacks in a controlled environment.

While this is a powerful weapon, the tool strictly incorporates safeguard mechanisms to prevent accidental deployment against non-authorized targets. For authorized cyber drills, the DDoS module offers:

Layer 7 Application Attacks: Targeting specific web server components (Apache, Nginx) by sending malformed HTTP requests that exhaust server resources, mimicking a real-world "Slowloris" or RUDY attack.

Amplification Vectors: The tool can coordinate with other agents (if deployed in a botnet-style simulation) to amplify UDP traffic, testing how well the company's scrubbing centers mitigate incoming floods.

Hybrid Warfare: The tool combines social engineering with DDoS to create a scenario where the defenders are distracted by an application-layer DDoS attack while the social engineering module attempts to steal credentials during the chaos—realistic scenario training for Blue Teams.

Use Cases Across the Industry
Expendable_Stoat is not limited to the white-hat community; it is a versatile instrument for several domains:

Social Engineers (Behavioral Assessments): The tool allows behavioral analysts to measure susceptibility to digital manipulation. By tracking click-through rates and interaction timelines, analysts can provide empirical data on employee vulnerability.

Academics and Researchers: Cyber security students and researchers can use the tool to study the propagation of malicious commands across different network topologies and communication protocols. The open architecture encourages academic exploration and the development of custom plugins.

Cyber Drills and Wargames: For military and enterprise defense forces, Expendable_Stoat serves as the "Red Team" standard. During large-scale cyber drills like Cyber Shield or Locked Shields, the tool’s ability to pivot between messaging platforms and launch coordinated DDoS attacks makes it invaluable for training incident response teams.

# Operational Security and Evasion

Expendable_Stoat is built with OPSEC (Operational Security) as a primary feature. The traffic generated by the tool mimics standard application usage. For example, when communicating over Slack, the payloads are segmented across multiple messages to resemble standard chat logs. The executable employs code obfuscation and dynamic loading of dependencies to evade static antivirus signatures. Furthermore, it supports "Jitter"—randomized delays in communication—to avoid generating a predictable network profile that could be flagged by behavioral analytics.

# Configuration and Execution

Deploying the tool is designed to be intuitive. Whether you are an operator using the CLI (Command Line Interface) or the rich web GUI, the process is streamlined. A typical workflow involves:

Setting up the Listener: The operator selects the platform (e.g., Discord) and inputs the required API tokens.

Generating Payloads: The operator customizes the implant based on the target OS (Windows, macOS, Linux).

Execution: The payload executes, establishing an outbound connection to the specified platform.

Commanding: The operator types commands naturally into the chat interface (e.g., gather_sysinfo or run_DDoS --target 192.168.x.x).

# Conclusion

In conclusion, Expendable_Stoat represents a paradigm shift in the accessibility and capability of cyber security frameworks. By integrating command execution via Discord, Slack, iMessage, Telegram, and the web, it defeats traditional network segmentation barriers. By incorporating a robust social engineering engine, it addresses the human variable. And by offering a controlled DDoS module, it prepares organizations for the worst-case scenarios.

Expendable_Stoat is not merely a tool; it is a force multiplier for security teams who require a dynamic, cross-platform solution that can keep pace with the speed of modern digital threats. Whether you are a seasoned penetration tester, an academic dissecting malware behaviors, or a drill coordinator trying to stress-test your Blue Team, Expendable_Stoat provides the agility, stealth, and power required to succeed in the cyber arena.




# How to clone the repo
```bash
git clone https://github.com/Iankulani/expendable_stoat.git
cd expendable_stoat
```

# How to run
```bash
python expendable_stoat.py
```

# Star History


