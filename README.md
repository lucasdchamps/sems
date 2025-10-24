# README

Sems is a simple Station Energy Management System modelization. It provides:
- a model of a fast-charging station
- a HTTP interface to interact with this model
- a load-balancing algorithm to optimize power allocation

## Running the project

Sems requires docker to run.

Setup the project with

```
$ docker compose build
```

Then run tests with

```
$ docker compose run --rm web bin/rails test
```

## Modelization

We modelize the real world station as follows. This model has two purposes:
- representing the station architecture
- saving the active sessions (i.e. the load balancing state)

```mermaid
classDiagram
direction LR
    Station *-- "1" Battery
    Station *-- "*" Charger
    Charger *-- "*" Connector
    Connector *--> "1" Session
    class Station {
        +String name
        +int grid_capacity
        +status()
        +create_session()
        +delete_session()
        -sessions()
        -load_balance()
    }
    class Charger {
        +int max_power
        +sessions()
        +create_session()
        +average_power()
    }
    class Connector {
        +available?()
    }
    class Session {
        +int vehicle_max_power
        +int allocated_power
    }
    class Battery {
        +int capacity
        +int power
    }
```

## Endpoints

Real world communications are modelized by HTTP endpoints. HTTP requests are handled by the model to inform about the active sessions or update them.

```
get "/stations/:station_id/status"

returns the active sessions and their allocated powers
```

```
post "/stations/:station_id/sessions { :charger_id, :connector_id, :vehicle_max_power }

creates a session for a specific charger, and connector, and load balances
the station's available power for its active sessions
```

```
delete "/stations/:station_id/sessions/:session_id

deletes the provided session and reallocates the station available power
```
