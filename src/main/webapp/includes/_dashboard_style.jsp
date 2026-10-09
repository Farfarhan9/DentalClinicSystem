<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    /* New Layout Styles for Sidebar and Main Content */
    .dashboard-layout {
        margin: 0;
        padding: 0;
        font-family: Arial, sans-serif;
        background-color: #f4f7f6;
    }
    .app-container {
        display: flex; /* Enables the sidebar/content layout */
        min-height: 100vh;
    }
    .sidebar {
        width: 250px;
        background-color: #2c3e50; /* Darker blue/grey */
        color: white;
        padding: 20px 0;
        box-shadow: 2px 0 5px rgba(0,0,0,0.1);
        display: flex;
        flex-direction: column;
    }
    .main-content-wrapper {
        flex-grow: 1;
        padding: 20px;
    }
    .header-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 10px 20px;
        background-color: #fff;
        border-bottom: 1px solid #ecf0f1;
        margin-bottom: 20px;
        border-radius: 5px;
    }
    /* Navigation styles (from previous step) */
    .nav-item {
        display: block;
        padding: 10px 20px;
        color: rgba(255, 255, 255, 0.8);
        text-decoration: none;
        transition: background-color 0.2s;
    }
    .nav-item:hover, .nav-item.active {
        background-color: #34495e;
        color: white;
    }
    /* Add this to the end of your existing <style> block in _dashboard_style.jsp */
	.navigation {
	    flex-grow: 1;
	    display: flex;
	    flex-direction: column;
	}
	.nav-section-title {
	    padding: 20px 20px 5px;
	    font-size: 0.75rem;
	    font-weight: bold;
	    color: #95a5a6;
	    text-transform: uppercase;
	    letter-spacing: 1px;
	}
	.user-profile small {
	    display: block;
	    font-size: 0.8rem;
	    color: #bdc3c7;
	}
</style>