# Solution Overview Document

## Overview
The Music Metadata Service is a system designed to provide a user-friendly interface where customers can access music metadata information, including the ability to add new tracks, edit artists' names, fetch artist tracks, and receive an "Artist of the Day."

## Architecture Design
![Overview](./images/architecture_overview.png)
Architecture overview

Our architecture will take advantage of AWS services, Kubernetes, and a MySQL database for storing data. The programming language of choice is Java, with Spring Boot for the backend RESTful API. Here's an overview of our tech stack:

1. **Java with Spring Boot**: The backend API providing the logic for all the required features.
2. **MySQL**: Our choice for data storage. It will contain two main tables, `Artists` and `Tracks`, with a one-to-many relationship (one artist can have many tracks).
3. **AWS EKS**: Amazon Elastic Kubernetes Service will be used to orchestrate our containerized applications. This will also handle our cron jobs for the "Artist of the Day" feature.

The REST API will have the following endpoints:

- `POST /track`: Add a new track
- `PUT /artist/{id}`: Edit an artist's name
- `GET /artist/{id}/tracks`: Fetch all tracks associated with a specific artist
- `GET /artistOfTheDay`: Fetch the Artist of the Day

## Data Model
Two primary entities exist in our data model: Artists and Tracks. 

- Artists: An artist has an `ID`, `Name`, and `ListOfTracks`.
- Tracks: A track has an `ID`, `Name`, `Genre`, `Length`, and `ArtistID`.

## Flow

- When a user wants to add a new track, they will hit the `/track` endpoint with track details. 
- To edit an artist's name, the user will provide the new name and the artist's ID to the `/artist/{id}` endpoint. 
- To fetch all tracks associated with a specific artist, the user will use the `/artist/{id}/tracks` endpoint.
- The Artist of the Day feature is a cyclical operation that is updated daily by an EKS cron job.

## Scalability and Fault Tolerance

The use of Kubernetes and the architecture design ensures scalability and fault tolerance. In case a service goes down, Kubernetes will restart it automatically. If traffic increases, Kubernetes allows for easy horizontal scaling.

## Security

The application will be secured using standard security practices, including network isolation, least privilege access, and secure handling of data.

In conclusion, by using a robust container orchestration system (EKS), a reliable and performant relational database system (MySQL), and a Kubernetes cron job for daily tasks, our solution can deliver a user-friendly interface where customers can effortlessly access music metadata information. The "Artist of the Day" feature is efficiently managed within the Kubernetes ecosystem, providing a more integrated solution.