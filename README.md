# Rostr Customer App

This repository contains the **Rostr Customer App**, a mobile application that allows customers to discover and connect with gig workers in their local area using the decentralized [Rostr](https://github.com/devcdis/rostr) network, powered by the Nostr protocol.

## Features

- **Service Discovery**: Browse a list of gig workers offering services near you by connecting to local relays.
- **Service Categorization**: Filter gig workers based on the services they offer and view their contact details for direct communication.
- **Relay Management**: Automatically fetch and update a list of nearby relays to ensure up-to-date service information.
- **Decentralized and Private**: The app utilizes the decentralized Rostr network, ensuring no central authority controls or collects your data.

## How It Works

The Rostr Customer App connects to **relay servers** that host listings of gig workers in your area. You can search for services, connect with gig workers, and update your relay list as you explore the marketplace.

1. **Connect to Relays**: Upon initial setup, the app fetches a list of relays from a master server. Over time, your app will automatically update this list as it interacts with different relays.
2. **View Local Services**: The app fetches information about local gig workers from these relays, including details such as their service offerings, contact info, and pricing.
3. **Direct Communication**: The app provides the necessary details for you to contact gig workers directly. All business dealings (pricing, scheduling, etc.) are handled outside the app.

Rostr is a decentralized FOSS gig marketplace built on the Nostr protocol. Learn more at [Rostr](https://github.com/devcdis/rostr).
