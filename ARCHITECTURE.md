# Architecture Decisions

## Technology Stack

- **Backend:** Ruby on Rails
- **Database:** PostgreSQL (single database, not split)
- **Frontend:** React + TypeScript + esbuild
- **CSS:** Bootstrap
- **Background Jobs:** None initially (no job queue service)
- **Development:** Docker Compose with hot reloading

## Development Requirements

### Docker Compose Hot Reloading
- Asset recompilation on file changes (esbuild watching)
- Rails server restart on Ruby file changes
- No container rebuilds for code changes
- Source code mounted as volumes
- Database data persisted across restarts

### Asset Pipeline Requirements
- **esbuild process:** Must run as separate process watching `app/javascript/`
- **CSS pipeline:** Rails asset pipeline or esbuild handling CSS/SCSS changes
- **File watching:** Both esbuild and Rails must detect host file changes through volume mounts
- **Port forwarding:** esbuild dev server (if used) needs port exposed for hot module replacement
- **Process management:** Use `foreman` with `Procfile.dev` for development processes

### File Structure
```
├── docker-compose.yml
├── Dockerfile.dev
├── app/
│   ├── javascript/           # React/TypeScript
│   └── views/                # Rails views (minimal)
├── config/
│   └── webpack/              # esbuild config
└── db/                       # PostgreSQL
```

## Implementation Notes
- Single database with Rails migrations
- Use JSON columns for flexible data
- Rails security defaults enabled
- Environment-based configuration

### Docker Configuration Details
- **Volume mounts:** Bind mount source code with proper permissions
- **Process management:** Single container running `foreman start -f Procfile.dev`
- **Procfile.dev:** Defines Rails server + esbuild watcher processes
- **Rails service:** Configure with `config.file_watcher` for container file detection
- **Network:** Internal docker network for service communication
- **Environment:** Set `RAILS_ENV=development` and Node environment variables
