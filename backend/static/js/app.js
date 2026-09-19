/**
 * SoundVault Application Controller
 * Handles routing, REST API communication, catalog rendering, DML Lab, and SQL Console.
 */

class SoundVaultApp {
  constructor() {
    this.currentView = 'home';
    this.activeUserId = 1;
    this.activeUserName = 'Aarav Mehta';
    this.songs = [];
    this.artists = [];
    this.albums = [];
    this.playlists = [];
    this.podcasts = [];
    this.dmlQueries = [];
    this.activeDmlIndex = 0;
    this.selectedSongForPlaylist = null;

    this.init();
  }

  async init() {
    this.bindEvents();
    await this.checkDbStatus();
    await this.loadInitialData();
    this.renderActiveView();
    if (window.lucide) lucide.createIcons();
  }

  bindEvents() {
    // Navigation items
    document.querySelectorAll('.sidebar-nav .nav-item[data-view]').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const view = e.currentTarget.dataset.view;
        this.switchView(view);
      });
    });

    // Topbar User Selector
    const userSelect = document.getElementById('user-select');
    if (userSelect) {
      userSelect.addEventListener('change', (e) => {
        this.activeUserId = parseInt(e.target.value);
        this.activeUserName = e.target.options[e.target.selectedIndex].text.split(' (')[0];
        this.onUserChanged();
      });
    }

    // Topbar Search
    const searchInput = document.getElementById('global-search-input');
    const clearSearch = document.getElementById('clear-search-btn');
    if (searchInput) {
      let debounceTimer;
      searchInput.addEventListener('input', (e) => {
        clearTimeout(debounceTimer);
        const val = e.target.value.trim();
        if (clearSearch) clearSearch.style.display = val ? 'flex' : 'none';
        debounceTimer = setTimeout(() => {
          this.handleSearch(val);
        }, 300);
      });
    }
    if (clearSearch) {
      clearSearch.addEventListener('click', () => {
        if (searchInput) {
          searchInput.value = '';
          clearSearch.style.display = 'none';
          this.handleSearch('');
        }
      });
    }

    // Quick refresh
    const refreshBtn = document.getElementById('quick-refresh-btn');
    if (refreshBtn) {
      refreshBtn.addEventListener('click', () => {
        this.loadInitialData();
        this.showToast('Data refreshed');
      });
    }

    // Genre filter chips
    document.querySelectorAll('#genre-filters .chip-filter').forEach(chip => {
      chip.addEventListener('click', (e) => {
        document.querySelectorAll('#genre-filters .chip-filter').forEach(c => c.classList.remove('active'));
        e.currentTarget.classList.add('active');
        const genreId = e.currentTarget.dataset.genre;
        this.filterSongsByGenre(genreId);
      });
    });

    // DML Lab execution button
    const btnRunDml = document.getElementById('btn-run-dml');
    if (btnRunDml) {
      btnRunDml.addEventListener('click', () => this.runCurrentDml());
    }

    // Copy SQL button
    const btnCopySql = document.getElementById('btn-copy-sql');
    if (btnCopySql) {
      btnCopySql.addEventListener('click', () => {
        const sql = document.getElementById('dml-q-sql').innerText;
        navigator.clipboard.writeText(sql);
        this.showToast('SQL copied to clipboard');
      });
    }

    // SQL Console
    const btnExecSql = document.getElementById('btn-exec-custom-sql');
    if (btnExecSql) {
      btnExecSql.addEventListener('click', () => this.executeCustomSql());
    }
    const sqlInput = document.getElementById('sql-editor-input');
    if (sqlInput) {
      sqlInput.addEventListener('keydown', (e) => {
        if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
          this.executeCustomSql();
        }
      });
    }
    const sampleQuerySelect = document.getElementById('sample-query-select');
    if (sampleQuerySelect) {
      sampleQuerySelect.addEventListener('change', (e) => {
        if (e.target.value && sqlInput) {
          sqlInput.value = e.target.value;
        }
      });
    }
    const btnClearSql = document.getElementById('btn-clear-sql');
    if (btnClearSql && sqlInput) {
      btnClearSql.addEventListener('click', () => {
        sqlInput.value = '';
        sqlInput.focus();
      });
    }

    // Modals
    const btnDbModal = document.getElementById('btn-open-db-modal');
    const pillDb = document.getElementById('db-status-pill');
    if (btnDbModal) btnDbModal.addEventListener('click', () => this.openDbModal());
    if (pillDb) pillDb.addEventListener('click', () => this.openDbModal());

    const btnNewPlaylist = document.getElementById('btn-create-playlist-modal');
    if (btnNewPlaylist) {
      btnNewPlaylist.addEventListener('click', () => this.openModal('create-playlist-modal'));
    }
  }

  switchView(viewName) {
    this.currentView = viewName;
    document.querySelectorAll('.sidebar-nav .nav-item').forEach(el => {
      el.classList.toggle('active', el.dataset.view === viewName);
    });

    document.querySelectorAll('.view-container').forEach(el => {
      el.classList.toggle('active', el.id === `view-${viewName}`);
    });

    this.renderActiveView();
    if (window.lucide) lucide.createIcons();
  }

  async checkDbStatus() {
    try {
      const res = await fetch('/api/status');
      const data = await res.json();
      const pillText = document.getElementById('status-engine-text');
      const pill = document.getElementById('db-status-pill');
      if (data.is_mysql) {
        pillText.textContent = 'MySQL (Active)';
        pill.querySelector('.status-dot').style.backgroundColor = 'var(--accent-green)';
      } else {
        pillText.textContent = 'SQLite (Active)';
        pill.querySelector('.status-dot').style.backgroundColor = '#eab308';
      }
    } catch (e) {
      console.error('Failed to check DB status:', e);
    }
  }

  async loadInitialData() {
    await Promise.all([
      this.loadStats(),
      this.loadSongs(),
      this.loadArtists(),
      this.loadAlbums(),
      this.loadPlaylists(),
      this.loadPodcasts(),
      this.loadDmlQueries(),
      this.loadSchema()
    ]);
  }

  async loadStats() {
    try {
      const res = await fetch('/api/stats');
      const stats = await res.json();
      document.getElementById('stat-songs').textContent = stats.song || 0;
      document.getElementById('stat-artists').textContent = stats.artist || 0;
      document.getElementById('stat-albums').textContent = stats.album || 0;
      document.getElementById('stat-playlists').textContent = stats.playlist || 0;
      document.getElementById('stat-podcasts').textContent = stats.podcast || 0;
      document.getElementById('badge-songs-count').textContent = stats.song || 0;
    } catch (e) {
      console.error(e);
    }
  }

  async loadSongs(query = '') {
    try {
      const url = query ? `/api/songs?q=${encodeURIComponent(query)}` : '/api/songs';
      const res = await fetch(url);
      this.songs = await res.json();
      this.renderSongsTable(this.songs);
      this.renderHomeRecent(this.songs.slice(0, 6));
    } catch (e) {
      console.error(e);
    }
  }

  async filterSongsByGenre(genreId) {
    try {
      const url = genreId ? `/api/songs?genre_id=${genreId}` : '/api/songs';
      const res = await fetch(url);
      const filtered = await res.json();
      this.renderSongsTable(filtered);
    } catch (e) {
      console.error(e);
    }
  }

  async loadArtists() {
    try {
      const res = await fetch('/api/artists');
      this.artists = await res.json();
      this.renderArtistsGrid();
      this.renderHomeTopArtists();
    } catch (e) {
      console.error(e);
    }
  }

  async loadAlbums() {
    try {
      const res = await fetch('/api/albums');
      this.albums = await res.json();
      this.renderAlbumsGrid();
    } catch (e) {
      console.error(e);
    }
  }

  async loadPlaylists() {
    try {
      const res = await fetch('/api/playlists');
      this.playlists = await res.json();
      this.renderPlaylistsGrid();
    } catch (e) {
      console.error(e);
    }
  }

  async loadPodcasts() {
    try {
      const res = await fetch('/api/podcasts');
      this.podcasts = await res.json();
      this.renderPodcastsList();
    } catch (e) {
      console.error(e);
    }
  }

  async loadHistory() {
    try {
      const res = await fetch(`/api/users/${this.activeUserId}/history`);
      const history = await res.json();
      this.renderHistoryTable(history);
    } catch (e) {
      console.error(e);
    }
  }

  async loadDmlQueries() {
    try {
      const res = await fetch('/api/dml-queries');
      this.dmlQueries = await res.json();
      this.renderDmlNavigator();
      this.displayDmlQuery(this.activeDmlIndex);
    } catch (e) {
      console.error(e);
    }
  }

  async loadSchema() {
    try {
      const res = await fetch('/api/schema');
      const schema = await res.json();
      this.renderSchemaAccordion(schema);
    } catch (e) {
      console.error(e);
    }
  }

  onUserChanged() {
    document.getElementById('hero-user-name').textContent = this.activeUserName;
    document.getElementById('section-user-name').textContent = this.activeUserName;
    document.getElementById('history-user-label').textContent = this.activeUserName;
    this.loadHistory();
    this.showToast(`Switched active user to ${this.activeUserName}`);
  }

  handleSearch(val) {
    if (this.currentView !== 'songs') {
      this.switchView('songs');
    }
    this.loadSongs(val);
  }

  renderActiveView() {
    if (this.currentView === 'history') {
      this.loadHistory();
    }
  }

  // --- RENDER METHODS ---

  renderHomeRecent(recent) {
    const container = document.getElementById('home-recent-songs');
    if (!container) return;
    container.innerHTML = recent.map(s => `
      <div class="music-card" onclick="app.playSongById(${s.Song_ID})">
        <div class="card-cover">
          <i data-lucide="music"></i>
          <div class="card-play-overlay">
            <i data-lucide="play"></i>
          </div>
        </div>
        <div class="card-info">
          <span class="card-title">${s.Title}</span>
          <span class="card-sub">${s.Artist_Name || 'Various'} • ${s.Album_Name || 'Single'}</span>
        </div>
      </div>
    `).join('');
    if (window.lucide) lucide.createIcons();
  }

  renderHomeTopArtists() {
    const container = document.getElementById('home-top-artists');
    if (!container) return;
    const top = this.artists.slice(0, 6);
    container.innerHTML = top.map(a => `
      <div class="artist-chip" onclick="app.showArtistDetails(${a.Artist_ID})">
        <div class="artist-avatar">${a.Artist_Name.charAt(0)}</div>
        <div>
          <div style="font-weight: 700; font-size: 0.9rem;">${a.Artist_Name}</div>
          <div style="font-size: 0.75rem; color: var(--text-muted);">${a.Country || 'Global'} • ${a.song_count} songs</div>
        </div>
      </div>
    `).join('');
    if (window.lucide) lucide.createIcons();
  }

  renderSongsTable(songs) {
    const tbody = document.getElementById('songs-tbody');
    if (!tbody) return;
    if (songs.length === 0) {
      tbody.innerHTML = `<tr><td colspan="8" class="text-muted text-center" style="padding: 2.5rem;">No songs match your criteria.</td></tr>`;
      return;
    }
    tbody.innerHTML = songs.map((s, idx) => `
      <tr data-song-id="${s.Song_ID}" class="${player.currentTrack && player.currentTrack.Song_ID === s.Song_ID && player.isPlaying ? 'playing' : ''}">
        <td>
          <button class="btn-ctrl" onclick="app.playSongById(${s.Song_ID})">
            <i data-lucide="play" style="width: 18px; height: 18px;"></i>
          </button>
        </td>
        <td class="text-muted">${idx + 1}</td>
        <td style="font-weight: 700;">${s.Title}</td>
        <td><a href="javascript:void(0)" onclick="app.showArtistDetails(${s.Artist_ID})" style="color: inherit; text-decoration: none;">${s.Artist_Name || 'Unknown'}</a></td>
        <td><a href="javascript:void(0)" onclick="app.showAlbumDetails(${s.Album_ID})" style="color: inherit; text-decoration: none;">${s.Album_Name || 'Single'}</a></td>
        <td class="text-muted" style="font-family: var(--font-mono); font-size: 0.82rem;">${player.formatTime(s.Duration)}</td>
        <td><span class="genre-tag">${s.Genre_Name || 'Pop'}</span></td>
        <td style="text-align: right;">
          <button class="btn-ctrl" onclick="app.openAddToPlaylistModal(${s.Song_ID}, '${s.Title.replace(/'/g, "\\'")}')" title="Add to Playlist">
            <i data-lucide="plus-circle" style="width: 18px; height: 18px;"></i>
          </button>
        </td>
      </tr>
    `).join('');
    if (window.lucide) lucide.createIcons();
  }

  renderArtistsGrid() {
    const container = document.getElementById('artists-grid');
    if (!container) return;
    container.innerHTML = this.artists.map(a => `
      <div class="music-card" onclick="app.showArtistDetails(${a.Artist_ID})">
        <div class="card-cover" style="border-radius: 50%;">
          <i data-lucide="mic-2"></i>
        </div>
        <div class="card-info" style="text-align: center;">
          <span class="card-title">${a.Artist_Name}</span>
          <span class="card-sub">${a.Country || 'International'}</span>
          <span style="font-size: 0.72rem; color: var(--accent-purple); font-weight: 700; margin-top: 0.2rem;">
            ${a.song_count} Songs • ${a.album_count} Albums
          </span>
        </div>
      </div>
    `).join('');
    if (window.lucide) lucide.createIcons();
  }

  renderAlbumsGrid() {
    const container = document.getElementById('albums-grid');
    if (!container) return;
    container.innerHTML = this.albums.map(a => `
      <div class="music-card" onclick="app.showAlbumDetails(${a.Album_ID})">
        <div class="card-cover">
          <i data-lucide="disc"></i>
          <div class="card-play-overlay">
            <i data-lucide="play"></i>
          </div>
        </div>
        <div class="card-info">
          <span class="card-title">${a.Album_Name}</span>
          <span class="card-sub">${a.Artist_Name} • ${a.Release_Date ? a.Release_Date.split('-')[0] : 'Album'}</span>
          <span style="font-size: 0.72rem; color: var(--text-dim); margin-top: 0.2rem;">
            ${a.song_count} Tracks
          </span>
        </div>
      </div>
    `).join('');
    if (window.lucide) lucide.createIcons();
  }

  renderPlaylistsGrid() {
    const container = document.getElementById('playlists-grid');
    if (!container) return;
    container.innerHTML = this.playlists.map(p => `
      <div class="music-card" onclick="app.showPlaylistDetails(${p.Playlist_ID})">
        <div class="card-cover" style="background: linear-gradient(135deg, #065f46, #0f172a);">
          <i data-lucide="list-music"></i>
          <div class="card-play-overlay">
            <i data-lucide="play"></i>
          </div>
        </div>
        <div class="card-info">
          <span class="card-title">${p.Playlist_Name}</span>
          <span class="card-sub">By ${p.Creator_Name} • ${p.song_count} songs</span>
        </div>
      </div>
    `).join('');
    if (window.lucide) lucide.createIcons();
  }

  renderPodcastsList() {
    const container = document.getElementById('podcasts-list');
    if (!container) return;
    container.innerHTML = this.podcasts.map(p => `
      <div class="dml-card mb-2">
        <div class="dml-card-header">
          <div>
            <span class="query-number-tag" style="color: var(--accent-orange);">PODCAST SHOW</span>
            <h2 class="dml-query-title">${p.Podcast_Name}</h2>
          </div>
          <button class="btn btn-outline" onclick="app.loadPodcastEpisodes(${p.Podcast_ID})">
            <i data-lucide="list"></i> View Episodes (${p.episode_count})
          </button>
        </div>
        <p class="dml-desc">${p.Description || 'No description provided.'}</p>
        <div id="episodes-container-${p.Podcast_ID}"></div>
      </div>
    `).join('');
    if (window.lucide) lucide.createIcons();
  }

  async loadPodcastEpisodes(podcastId) {
    try {
      const res = await fetch(`/api/podcasts/${podcastId}`);
      const data = await res.json();
      const container = document.getElementById(`episodes-container-${podcastId}`);
      if (!container) return;
      container.innerHTML = `
        <div class="table-card mt-3">
          <table class="data-table">
            <thead>
              <tr>
                <th style="width: 50px;">Play</th>
                <th>Episode Title</th>
                <th>Duration</th>
                <th>Release Date</th>
              </tr>
            </thead>
            <tbody>
              ${(data.episodes || []).map(e => `
                <tr>
                  <td>
                    <button class="btn-ctrl" onclick="app.playEpisode('${e.Title.replace(/'/g, "\\'")}', '${data.Podcast_Name}', ${e.Duration})">
                      <i data-lucide="play" style="width: 18px; height: 18px;"></i>
                    </button>
                  </td>
                  <td style="font-weight: 700;">${e.Title}</td>
                  <td class="text-muted" style="font-family: var(--font-mono);">${player.formatTime(e.Duration)}</td>
                  <td class="text-muted">${e.Release_Date || 'Recent'}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      `;
      if (window.lucide) lucide.createIcons();
    } catch (e) {
      console.error(e);
    }
  }

  playEpisode(title, podcastName, duration) {
    player.setTrack({
      Song_ID: 9999,
      Title: title,
      Artist_Name: podcastName,
      Album_Name: 'Podcast Episode',
      Duration: duration
    });
    this.showToast(`Now playing episode: ${title}`);
  }

  renderHistoryTable(history) {
    const tbody = document.getElementById('history-tbody');
    if (!tbody) return;
    if (history.length === 0) {
      tbody.innerHTML = `<tr><td colspan="5" class="text-muted text-center" style="padding: 2rem;">No listening history recorded for this user yet.</td></tr>`;
      return;
    }
    tbody.innerHTML = history.map(h => `
      <tr>
        <td>
          <button class="btn-ctrl" onclick="app.playSongById(${h.Song_ID})">
            <i data-lucide="play" style="width: 18px; height: 18px;"></i>
          </button>
        </td>
        <td style="font-weight: 700;">${h.Title}</td>
        <td>${h.Artist_Name || 'Unknown'}</td>
        <td class="text-muted">${h.Album_Name || 'Single'}</td>
        <td class="text-muted" style="font-family: var(--font-mono); font-size: 0.8rem;">${h.Played_At}</td>
      </tr>
    `).join('');
    if (window.lucide) lucide.createIcons();
  }

  // --- 10 DML QUERIES LAB ---

  renderDmlNavigator() {
    const bar = document.getElementById('dml-pills-bar');
    if (!bar) return;
    bar.innerHTML = this.dmlQueries.map((q, idx) => `
      <button class="dml-pill ${idx === this.activeDmlIndex ? 'active' : ''}" onclick="app.displayDmlQuery(${idx})">
        Query ${q.id}
      </button>
    `).join('');
  }

  displayDmlQuery(index) {
    this.activeDmlIndex = index;
    document.querySelectorAll('.dml-pill').forEach((p, idx) => {
      p.classList.toggle('active', idx === index);
    });

    const q = this.dmlQueries[index];
    if (!q) return;

    document.getElementById('dml-q-num').textContent = `DML Query ${q.id} of 10`;
    document.getElementById('dml-q-title').textContent = q.title;
    document.getElementById('dml-q-desc').textContent = q.description;
    document.getElementById('dml-q-sql').textContent = q.sql;
    document.getElementById('dml-meta-rows').textContent = q.count || 0;
    document.getElementById('dml-meta-time').textContent = `${q.execution_time_ms || 0} ms`;

    this.renderDmlResultsTable(q.columns || [], q.rows || []);
  }

  async runCurrentDml() {
    const q = this.dmlQueries[this.activeDmlIndex];
    if (!q) return;

    try {
      const res = await fetch(`/api/dml-queries/${q.id}`);
      const updated = await res.json();
      this.dmlQueries[this.activeDmlIndex] = { ...q, ...updated };
      this.displayDmlQuery(this.activeDmlIndex);
      this.showToast(`Executed DML Query ${q.id} in ${updated.execution_time_ms}ms`);
    } catch (e) {
      this.showToast(`Error executing query: ${e}`);
    }
  }

  renderDmlResultsTable(columns, rows) {
    const thead = document.getElementById('dml-results-thead');
    const tbody = document.getElementById('dml-results-tbody');
    if (!thead || !tbody) return;

    if (columns.length === 0 || rows.length === 0) {
      thead.innerHTML = '';
      tbody.innerHTML = `<tr><td class="text-muted text-center" style="padding: 2rem;">No rows returned</td></tr>`;
      return;
    }

    thead.innerHTML = `<tr>${columns.map(c => `<th>${c}</th>`).join('')}</tr>`;
    tbody.innerHTML = rows.map(r => `
      <tr>
        ${columns.map(c => `<td>${r[c] !== null && r[c] !== undefined ? r[c] : 'NULL'}</td>`).join('')}
      </tr>
    `).join('');
  }

  // --- SQL CONSOLE ---

  async executeCustomSql() {
    const input = document.getElementById('sql-editor-input');
    const sql = input ? input.value.trim() : '';
    if (!sql) return;

    const feedback = document.getElementById('custom-query-feedback');
    feedback.style.display = 'none';

    try {
      const res = await fetch('/api/custom-query', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ query: sql })
      });
      const data = await res.json();

      if (!data.success) {
        feedback.style.display = 'block';
        feedback.className = 'status-summary-box';
        feedback.style.borderColor = 'var(--accent-red)';
        feedback.innerHTML = `<span style="color: var(--accent-red); font-weight: 700;">SQL Error:</span> ${data.error}`;
        return;
      }

      document.getElementById('custom-sql-count').textContent = `${data.count || data.affected_rows || 0} rows (${data.execution_time_ms} ms)`;

      const thead = document.getElementById('custom-sql-thead');
      const tbody = document.getElementById('custom-sql-tbody');

      if (data.columns && data.columns.length > 0) {
        thead.innerHTML = `<tr>${data.columns.map(c => `<th>${c}</th>`).join('')}</tr>`;
        tbody.innerHTML = data.rows.map(r => `
          <tr>${data.columns.map(c => `<td>${r[c] !== null && r[c] !== undefined ? r[c] : 'NULL'}</td>`).join('')}</tr>
        `).join('');
      } else {
        thead.innerHTML = `<tr><th>Status</th></tr>`;
        tbody.innerHTML = `<tr><td>Query executed successfully. Affected rows: ${data.affected_rows || 0}</td></tr>`;
      }

      this.showToast(`Query executed in ${data.execution_time_ms}ms`);
    } catch (e) {
      this.showToast(`Execution failed: ${e}`);
    }
  }

  renderSchemaAccordion(schema) {
    const container = document.getElementById('schema-accordion');
    if (!container) return;
    document.getElementById('schema-table-count').textContent = `${schema.length} Tables`;

    container.innerHTML = schema.map(tbl => `
      <div class="table-schema-item">
        <div class="table-schema-header" onclick="this.nextElementSibling.style.display = (this.nextElementSibling.style.display === 'none' ? 'flex' : 'none')">
          <span>📁 ${tbl.table}</span>
          <span class="badge">${tbl.row_count} rows</span>
        </div>
        <div class="table-schema-body" style="display: none;">
          ${tbl.columns.map(c => `
            <div>
              <b style="color: ${c.primary_key ? 'var(--accent-green)' : '#93c5fd'}">${c.name}</b>: ${c.type}
              ${c.primary_key ? '<span style="color: var(--accent-green)">[PK]</span>' : ''}
              ${c.notnull ? '<span style="color: var(--text-dim)">NOT NULL</span>' : ''}
            </div>
          `).join('')}
        </div>
      </div>
    `).join('');
  }

  // --- PLAYLIST ACTIONS ---

  openAddToPlaylistModal(songId, songTitle) {
    this.selectedSongForPlaylist = songId;
    document.getElementById('add-modal-song-title').textContent = songTitle;
    const choiceList = document.getElementById('playlist-choice-list');
    choiceList.innerHTML = this.playlists.map(p => `
      <div class="artist-chip mb-2" onclick="app.addSongToPlaylistConfirmed(${p.Playlist_ID})">
        <div class="artist-avatar" style="background: var(--accent-green); color: #000;">
          <i data-lucide="music" style="width: 20px; height: 20px;"></i>
        </div>
        <div style="flex: 1;">
          <div style="font-weight: 700;">${p.Playlist_Name}</div>
          <div style="font-size: 0.75rem; color: var(--text-muted);">${p.song_count} tracks</div>
        </div>
        <i data-lucide="plus" style="width: 18px; height: 18px; color: var(--accent-green);"></i>
      </div>
    `).join('');
    if (window.lucide) lucide.createIcons();
    this.openModal('add-to-playlist-modal');
  }

  async addSongToPlaylistConfirmed(playlistId) {
    if (!this.selectedSongForPlaylist) return;
    try {
      const res = await fetch(`/api/playlists/${playlistId}/songs`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ song_id: this.selectedSongForPlaylist })
      });
      const data = await res.json();
      this.closeModal('add-to-playlist-modal');
      this.loadPlaylists();
      this.showToast('Song added to playlist successfully!');
    } catch (e) {
      this.showToast('Failed to add song to playlist');
    }
  }

  async submitNewPlaylist() {
    const input = document.getElementById('new-playlist-name');
    const name = input ? input.value.trim() : '';
    if (!name) return;

    try {
      const res = await fetch('/api/playlists', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, user_id: this.activeUserId })
      });
      this.closeModal('create-playlist-modal');
      if (input) input.value = '';
      await this.loadPlaylists();
      this.showToast(`Playlist "${name}" created!`);
    } catch (e) {
      this.showToast('Error creating playlist');
    }
  }

  async showPlaylistDetails(playlistId) {
    try {
      const res = await fetch(`/api/playlists/${playlistId}`);
      const data = await res.json();
      document.getElementById('modal-playlist-name').textContent = `${data.Playlist_Name} (by ${data.Creator_Name})`;
      const tbody = document.getElementById('playlist-details-tbody');
      if ((data.songs || []).length === 0) {
        tbody.innerHTML = `<tr><td colspan="6" class="text-muted text-center" style="padding: 2rem;">No songs in this playlist yet.</td></tr>`;
      } else {
        tbody.innerHTML = data.songs.map(s => `
          <tr>
            <td>
              <button class="btn-ctrl" onclick="app.playSongById(${s.Song_ID})">
                <i data-lucide="play" style="width: 18px; height: 18px;"></i>
              </button>
            </td>
            <td style="font-weight: 700;">${s.Title}</td>
            <td>${s.Artist_Name || 'Unknown'}</td>
            <td class="text-muted">${s.Album_Name || 'Single'}</td>
            <td class="text-muted" style="font-family: var(--font-mono);">${player.formatTime(s.Duration)}</td>
            <td style="text-align: right;">
              <button class="btn-ctrl" onclick="app.removeSongFromPlaylist(${playlistId}, ${s.Song_ID})" title="Remove">
                <i data-lucide="trash-2" style="width: 16px; height: 16px; color: var(--accent-red);"></i>
              </button>
            </td>
          </tr>
        `).join('');
      }
      if (window.lucide) lucide.createIcons();
      this.openModal('playlist-details-modal');
    } catch (e) {
      console.error(e);
    }
  }

  async removeSongFromPlaylist(playlistId, songId) {
    try {
      await fetch(`/api/playlists/${playlistId}/songs/${songId}`, { method: 'DELETE' });
      this.showPlaylistDetails(playlistId);
      this.loadPlaylists();
      this.showToast('Removed track from playlist');
    } catch (e) {
      this.showToast('Failed to remove track');
    }
  }

  // --- ARTIST & ALBUM DETAILS MODALS ---

  async showArtistDetails(artistId) {
    try {
      const res = await fetch(`/api/artists/${artistId}`);
      const data = await res.json();
      document.getElementById('modal-artist-name').textContent = data.Artist_Name;
      const body = document.getElementById('modal-artist-body');
      body.innerHTML = `
        <div style="display: flex; gap: 1.5rem; align-items: center; margin-bottom: 1.5rem;">
          <div class="artist-avatar" style="width: 72px; height: 72px; font-size: 1.8rem;">
            ${data.Artist_Name.charAt(0)}
          </div>
          <div>
            <h3 style="font-size: 1.3rem;">${data.Artist_Name}</h3>
            <p class="text-muted">Origin: <b>${data.Country || 'Unknown'}</b></p>
          </div>
        </div>

        <h4 class="mb-2">Albums (${(data.albums || []).length})</h4>
        <div class="cards-grid mb-2" style="grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));">
          ${(data.albums || []).map(alb => `
            <div class="music-card" onclick="app.showAlbumDetails(${alb.Album_ID})">
              <div class="card-cover"><i data-lucide="disc"></i></div>
              <div class="card-info">
                <span class="card-title">${alb.Album_Name}</span>
                <span class="card-sub">${alb.Release_Date ? alb.Release_Date.split('-')[0] : ''}</span>
              </div>
            </div>
          `).join('')}
        </div>

        <h4 class="mb-2" style="margin-top: 1.5rem;">Songs (${(data.songs || []).length})</h4>
        <div class="table-card">
          <table class="data-table">
            <thead>
              <tr>
                <th style="width: 50px;">Play</th>
                <th>Title</th>
                <th>Album</th>
                <th>Genre</th>
                <th>Duration</th>
              </tr>
            </thead>
            <tbody>
              ${(data.songs || []).map(s => `
                <tr>
                  <td>
                    <button class="btn-ctrl" onclick="app.playSongById(${s.Song_ID})">
                      <i data-lucide="play" style="width: 18px; height: 18px;"></i>
                    </button>
                  </td>
                  <td style="font-weight: 700;">${s.Title}</td>
                  <td>${s.Album_Name}</td>
                  <td><span class="genre-tag">${s.Genre_Name}</span></td>
                  <td class="text-muted" style="font-family: var(--font-mono);">${player.formatTime(s.Duration)}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      `;
      if (window.lucide) lucide.createIcons();
      this.openModal('artist-details-modal');
    } catch (e) {
      console.error(e);
    }
  }

  async showAlbumDetails(albumId) {
    try {
      const res = await fetch(`/api/albums/${albumId}`);
      const data = await res.json();
      document.getElementById('modal-artist-name').textContent = `${data.Album_Name} (${data.Artist_Name})`;
      const body = document.getElementById('modal-artist-body');
      body.innerHTML = `
        <div style="display: flex; gap: 1.5rem; align-items: center; margin-bottom: 1.5rem;">
          <div class="vinyl-art" style="width: 72px; height: 72px;">
            <i data-lucide="disc" style="width: 32px; height: 32px;"></i>
          </div>
          <div>
            <h3 style="font-size: 1.3rem;">${data.Album_Name}</h3>
            <p class="text-muted">By <b>${data.Artist_Name}</b> • Released: <b>${data.Release_Date || 'N/A'}</b></p>
          </div>
        </div>

        <h4 class="mb-2">Tracklist (${(data.songs || []).length} songs)</h4>
        <div class="table-card">
          <table class="data-table">
            <thead>
              <tr>
                <th style="width: 50px;">Play</th>
                <th>Title</th>
                <th>Genre</th>
                <th>Duration</th>
              </tr>
            </thead>
            <tbody>
              ${(data.songs || []).map(s => `
                <tr>
                  <td>
                    <button class="btn-ctrl" onclick="app.playSongById(${s.Song_ID})">
                      <i data-lucide="play" style="width: 18px; height: 18px;"></i>
                    </button>
                  </td>
                  <td style="font-weight: 700;">${s.Title}</td>
                  <td><span class="genre-tag">${s.Genre_Name}</span></td>
                  <td class="text-muted" style="font-family: var(--font-mono);">${player.formatTime(s.Duration)}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
      `;
      if (window.lucide) lucide.createIcons();
      this.openModal('artist-details-modal');
    } catch (e) {
      console.error(e);
    }
  }

  // --- PLAYBACK TRIGGERS ---

  playQuickSong(songId) {
    this.playSongById(songId);
  }

  playSongById(songId) {
    if (player.currentTrack && player.currentTrack.Song_ID === songId) {
      player.togglePlay();
      return;
    }
    const track = this.songs.find(s => s.Song_ID === songId);
    if (track) {
      player.setTrack(track, this.songs);
      this.showToast(`Now playing: ${track.Title}`);
    }
  }

  // --- DB MODAL & ACTIONS ---

  async openDbModal() {
    try {
      const res = await fetch('/api/status');
      const data = await res.json();
      const statusBox = document.getElementById('db-modal-status-box');
      if (statusBox) {
        statusBox.innerHTML = `
          <div>Active Engine: <b style="color: ${data.is_mysql ? 'var(--accent-green)' : '#eab308'}">${data.engine.toUpperCase()}</b></div>
          <div style="font-size: 0.8rem; color: var(--text-muted); margin-top: 0.25rem;">
            ${data.is_mysql ? `Connected to MySQL database "${data.database}" on ${data.host}:${data.port}` : `Fallback to SQLite at ${data.sqlite_file}`}
          </div>
          ${data.last_error ? `<div style="color: var(--accent-red); margin-top: 0.5rem; font-size: 0.78rem;">Last status note: ${data.last_error}</div>` : ''}
        `;
      }
      this.openModal('db-config-modal');
    } catch (e) {
      console.error(e);
    }
  }

  async saveDbConfig() {
    const host = document.getElementById('cfg-host').value;
    const port = document.getElementById('cfg-port').value;
    const user = document.getElementById('cfg-user').value;
    const password = document.getElementById('cfg-password').value;
    const database = document.getElementById('cfg-database').value;

    const btn = document.getElementById('btn-save-db-config');
    btn.innerHTML = 'Testing Connection...';
    btn.disabled = true;

    try {
      const res = await fetch('/api/db/config', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ host, port, user, password, database })
      });
      const data = await res.json();
      btn.innerHTML = '<i data-lucide="check"></i> Test & Connect MySQL';
      btn.disabled = false;

      if (data.success) {
        this.showToast('Successfully connected to MySQL database!');
        this.closeModal('db-config-modal');
        await this.checkDbStatus();
        this.loadInitialData();
      } else {
        this.showToast(`Connection failed: ${data.status.last_error || 'Check credentials'}`);
        this.openDbModal();
      }
    } catch (e) {
      btn.innerHTML = '<i data-lucide="check"></i> Test & Connect MySQL';
      btn.disabled = false;
      this.showToast(`Connection error: ${e}`);
    }
  }

  async resetDbData() {
    if (!confirm('Reload all tables and insert sample data from SQL scripts?')) return;
    try {
      const res = await fetch('/api/db/init', { method: 'POST' });
      const data = await res.json();
      if (data.success) {
        this.showToast('Database reloaded with sample dataset!');
        this.closeModal('db-config-modal');
        this.loadInitialData();
      }
    } catch (e) {
      this.showToast('Failed to reset data');
    }
  }

  // --- MODAL & TOAST UTILITIES ---

  openModal(modalId) {
    const m = document.getElementById(modalId);
    if (m) m.classList.add('active');
  }

  closeModal(modalId) {
    const m = document.getElementById(modalId);
    if (m) m.classList.remove('active');
  }

  showToast(message) {
    const container = document.getElementById('toast-container');
    if (!container) return;
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.textContent = message;
    container.appendChild(toast);
    setTimeout(() => {
      toast.style.opacity = '0';
      toast.style.transform = 'translateY(10px)';
      toast.style.transition = 'all 0.25s ease';
      setTimeout(() => toast.remove(), 250);
    }, 3200);
  }
}

// Instantiate global app
window.app = new SoundVaultApp();
