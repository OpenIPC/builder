#!/usr/bin/haserl
Content-type: text/html; charset=UTF-8
Cache-Control: no-store
Pragma: no-cache

<!DOCTYPE html>
<html lang="en" data-bs-theme="<%= ${webui_theme:=dark} %>">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title><% html_title %></title>
	<link rel="stylesheet" href="/a/bootstrap.min.css">
	<link rel="stylesheet" href="/a/bootstrap.override.css">
	<script src="/a/bootstrap.bundle.min.js"></script>
	<script src="/a/main.js"></script>
</head>

<body id="page-<%= $pagename %>" class="<%= $fw_variant %>">
	<nav class="navbar navbar-expand-lg bg-body-tertiary">
		<div class="container">
			<a class="navbar-brand" href="status.cgi"><img alt="Image: OpenIPC logo" height="32" src="/a/logo.svg"><span class="x-small ms-1"><%= $fw_variant %></span></a>
			<button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
				<span class="navbar-toggler-icon"></span>
			</button>
			<div class="collapse navbar-collapse justify-content-end" id="navbarNav">
				<ul class="navbar-nav">
					<li class="nav-item dropdown">
						<a aria-expanded="false" class="nav-link dropdown-toggle" data-bs-toggle="dropdown" href="#" id="dropdownInformation" role="button">Information</a>
						<ul aria-labelledby="dropdownInformation" class="dropdown-menu">
							<li><a class="dropdown-item" href="status.cgi">Status</a></li>
							<li><hr class="dropdown-divider"></li>
							<li><a class="dropdown-item" href="info-majestic.cgi">Majestic</a></li>
							<li><a class="dropdown-item" href="info-kernel.cgi">Kernel</a></li>
							<li><a class="dropdown-item" href="info-overlay.cgi">Overlay</a></li>
						</ul>
					</li>
					<li class="nav-item dropdown">
						<a aria-expanded="false" class="nav-link dropdown-toggle" data-bs-toggle="dropdown" href="#" id="dropdownMajestic" role="button">Majestic</a>
						<ul aria-labelledby="dropdownMajestic" class="dropdown-menu">
							<li><a class="dropdown-item" href="mj-settings.cgi">Settings</a></li>
							<li><hr class="dropdown-divider"></li>
							<li><a class="dropdown-item" href="mj-configuration.cgi">Configuration</a></li>
							<li><a class="dropdown-item" href="mj-endpoints.cgi">Endpoints</a></li>
						</ul>
					</li>
					<li class="nav-item dropdown">
						<a aria-expanded="false" class="nav-link dropdown-toggle" data-bs-toggle="dropdown" href="#" id="dropdownSettings" role="button">Firmware</a>
						<ul aria-labelledby="dropdownSettings" class="dropdown-menu">
							<li><a class="dropdown-item" href="fw-time.cgi">Time</a></li>
							<li><a class="dropdown-item" href="fw-interface.cgi">Interface</a></li>
							<li><hr class="dropdown-divider"></li>
							<li><a class="dropdown-item" href="fw-update.cgi">Update</a></li>
							<li><a class="dropdown-item" href="fw-settings.cgi">Settings</a></li>
						</ul>
					</li>
					<li class="nav-item dropdown">
						<a aria-expanded="false" class="nav-link dropdown-toggle" data-bs-toggle="dropdown" href="#" id="dropdownTools" role="button">Tools</a>
						<ul aria-labelledby="dropdownTools" class="dropdown-menu">
							<li><a class="dropdown-item" href="tool-files.cgi">Files</a></li>
							<% if [ -e /dev/mmcblk0 ]; then %>
								<li><a class="dropdown-item" href="tool-sdcard.cgi">SDcard</a></li>
							<% fi %>
						</ul>
					</li>
					<li class="nav-item"><a class="nav-link" href="preview.cgi">Preview</a></li>
				</ul>
			</div>
		</div>
	</nav>

	<main class="pb-4">
		<div class="container" style="min-height: 85vh">
			<div class="row mt-1 x-small">
				<div class="col-lg-2">
					<div id="pb-memory" class="progress my-1" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"><div class="progress-bar"></div></div>
					<div id="pb-overlay" class="progress my-1" role="progressbar" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100"><div class="progress-bar"></div></div>
				</div>

				<div class="col-md-6 mb-2">
					<%= $(signature) %>
				</div>

				<div class="col-1" id="daynight_value"></div>
				<div class="col-md-4 col-lg-3 mb-2 text-end">
					<div id="time-now"></div>
					<div class="text-secondary" id="soc-temp"></div>
				</div>
			</div>

<% if [ -z "$network_gateway" ]; then %>
<div class="alert alert-warning">
	<p class="mb-0">Internet connection not available, please <a href="fw-network.cgi">check your network settings</a>.</p>
</div>
<% fi %>

<% if [ ! -e $(get_config) ]; then %>
<div class="alert alert-danger">
	<p class="mb-0">Majestic configuration not found, please <a href="mj-configuration.cgi">check your Majestic settings</a>.</p>
</div>
<% fi %>

<% if [ "$(cat /etc/TZ)" != "$TZ" ] || [ -e /tmp/system-reboot ]; then %>
<div class="alert alert-danger">
	<h3>Warning.</h3>
	<p>System settings have been updated, restart to apply pending changes.</p>
	<span class="d-flex gap-3">
		<a class="btn btn-danger" href="fw-restart.cgi">Restart camera</a>
	</span>
</div>
<% fi %>

<h2><%= $page_title %></h2>
<% log_read %>
