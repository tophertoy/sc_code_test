# ShiftCare Technical Challenge

A Ruby on Rails application that provides client search and duplicate detection functionality through both command-line interface.

## Setup

### Prerequisites
- Ruby 3.4.2
- PostgreSQL
  - **macOS**: `brew install postgresql` ([Homebrew](https://brew.sh/))
  - **Other systems**: [PostgreSQL Downloads](https://www.postgresql.org/download/)
- Bundler
  - **All systems**: `gem install bundler` (requires Ruby)

### Installation
```bash
git clone <repository-url>
cd shiftcare
bundle install
rails db:create
```

## Usage

### Command Line Interface
```bash
# Import clients from JSON file
rails clients:import

# Search clients by name
rails "clients:search[john]"

# Search with pagination (page 1, 25 per page)
rails "clients:search[john,1,25]"

# Search all clients (empty query) with pagination
rails "clients:search[,1,25]"

# Search with custom pagination
rails "clients:search[john,1,10]"  # page 2, 10 per page

# Find duplicate emails
rails clients:duplicates
```

## Assumptions & Decisions

- **Rails over Sinatra**: Chosen for better structure and future extensibility
- **PostgreSQL**: Selected for production-ready database capabilities
- **Service Objects**: Used for business logic following SOLID principles

## Known Limitations

- Limited to name-based search initially

## Future Improvements

- **Dynamic Search**: Allow searching any field, not just names
- **Elasticsearch Integration**: For better search performance and features
- **Caching**: Implement Redis for improved performance
- **Background Jobs**: Process large datasets asynchronously