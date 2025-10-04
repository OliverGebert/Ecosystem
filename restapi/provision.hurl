# Create a new ecosystem
POST http://localhost:8040/ecosystems/deleteall
Content-Type: application/json

{
}
HTTP/1.1 200

# Create a new ecosystem
POST http://localhost:8040/ecosystems
Content-Type: application/json

{
  "id": "eco1",
  "name": "Rainforest",
  "description": "Tropical ecosystem"
}
HTTP/1.1 201

# Create a new ecosystem
POST http://localhost:8040/ecosystems
Content-Type: application/json

{
  "id": "eco2",
  "name": "Rainforest",
  "description": "Tropical ecosystem"
}
HTTP/1.1 201

# Create a new ecosystem
POST http://localhost:8040/ecosystems
Content-Type: application/json

{
  "id": "eco3",
  "name": "Lake",
  "description": "Tropical ecosystem"
}
HTTP/1.1 201

# Create a new ecosystem
POST http://localhost:8040/ecosystems
Content-Type: application/json

{
  "id": "eco4",
  "name": "Lake",
  "description": "Tropical ecosystem"
}
HTTP/1.1 201

# Create a new ecosystem
POST http://localhost:8040/ecosystems
Content-Type: application/json

{
  "id": "eco5",
  "name": "Sand",
  "description": "Tropical ecosystem"
}
HTTP/1.1 201

# List all ecosystems
GET http://localhost:8040/ecosystems
HTTP/1.1 200

