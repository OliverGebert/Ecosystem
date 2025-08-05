# List all ecosystems
GET http://localhost:8040/ecosystems
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

# Get the created ecosystem
GET http://localhost:8040/ecosystems/eco1
HTTP/1.1 200

# List all patches
GET http://localhost:8040/patches
HTTP/1.1 200

# Create a new patch
POST http://localhost:8040/patches
Content-Type: application/json

{
  "id": "patch1",
  "ecosystemId": "eco1",
  "name": "Area 51",
  "details": "First area of study"
}
HTTP/1.1 201

# Get the created patch
GET http://localhost:8040/patches/patch1
HTTP/1.1 200

