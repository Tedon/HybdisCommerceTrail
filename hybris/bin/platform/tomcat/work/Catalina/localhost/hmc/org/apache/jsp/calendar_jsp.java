/*
 * Generated by the Jasper component of Apache Tomcat
 * Version: JspCServletContext/1.0
 * Generated at: 2015-11-04 09:30:55 UTC
 * Note: The last modified time of this file was set to
 *       the last modified time of the source file after
 *       generation to assist with modification tracking.
 */
package org.apache.jsp;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;

public final class calendar_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent {

  private static final javax.servlet.jsp.JspFactory _jspxFactory =
          javax.servlet.jsp.JspFactory.getDefaultFactory();

  private static java.util.Map<java.lang.String,java.lang.Long> _jspx_dependants;

  private javax.el.ExpressionFactory _el_expressionfactory;
  private org.apache.tomcat.InstanceManager _jsp_instancemanager;

  public java.util.Map<java.lang.String,java.lang.Long> getDependants() {
    return _jspx_dependants;
  }

  public void _jspInit() {
    _el_expressionfactory = _jspxFactory.getJspApplicationContext(getServletConfig().getServletContext()).getExpressionFactory();
    _jsp_instancemanager = org.apache.jasper.runtime.InstanceManagerFactory.getInstanceManager(getServletConfig());
  }

  public void _jspDestroy() {
  }

  public void _jspService(final javax.servlet.http.HttpServletRequest request, final javax.servlet.http.HttpServletResponse response)
        throws java.io.IOException, javax.servlet.ServletException {

    final javax.servlet.jsp.PageContext pageContext;
    javax.servlet.http.HttpSession session = null;
    final javax.servlet.ServletContext application;
    final javax.servlet.ServletConfig config;
    javax.servlet.jsp.JspWriter out = null;
    final java.lang.Object page = this;
    javax.servlet.jsp.JspWriter _jspx_out = null;
    javax.servlet.jsp.PageContext _jspx_page_context = null;


    try {
      response.setContentType("text/html");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;

      out.write("<html>\r\n\r\n<head>\r\n\t<script language=\"JavaScript\" src=\"js/date.js\"></script>\r\n\r\n\t<link rel=\"stylesheet\" type=\"text/css\" media=\"all\" href=\"css/hmc.css\">\r\n\r\n\t<script language=\"JavaScript\">\r\n\r\n\t\tfunction swapImage(id, img)\r\n\t\t{\r\n\t\t\tdocument.getElementById( id ).src = img;\r\n\t\t}\r\n\t\t\r\n\t\tvar re_url = new RegExp('datetime=(\\\\-?\\\\d+)');\r\n\t\tvar dt_current = (re_url.exec(String(window.location)) ? new Date(new Number(RegExp.$1)) : new Date());\r\n\t\t\r\n\t\tvar re_id = new RegExp('id=(\\\\d+)');\r\n\t\tvar num_id = (re_id.exec(String(window.location)) ? new Number(RegExp.$1) : 0);\r\n\t\t\r\n\t\tvar obj_caller = (window.opener ? window.opener.calendars[num_id] : null);\r\n\t\t\r\n\t\tif( obj_caller ) \r\n\t\t{\r\n\t\t\t// get same date in the previous year\r\n\t\t\tvar dt_prev_year = new Date(dt_current);\r\n\t\t\tdt_prev_year.setFullYear(dt_prev_year.getFullYear() - 1);\r\n\t\t\tif (dt_prev_year.getDate() != dt_current.getDate())\r\n\t\t\t{\r\n\t\t\t\tdt_prev_year.setDate(0);\r\n\t\t\t}\r\n\t\t\t\r\n\t\t\t// get same date in the next year\r\n\t\t\tvar dt_next_year = new Date(dt_current);\r\n\t\t\tdt_next_year.setFullYear(dt_next_year.getFullYear() + 1);\r\n");
      out.write("\t\t\tif (dt_next_year.getDate() != dt_current.getDate())\r\n\t\t\t{\r\n\t\t\t\tdt_next_year.setDate(0);\r\n\t\t\t}\r\n\t\t}\r\n\t\t\r\n\t\t// get same date in the previous month\r\n\t\tvar dt_prev_month = new Date(dt_current);\r\n\t\tdt_prev_month.setMonth(dt_prev_month.getMonth() - 1);\r\n\t\tif (dt_prev_month.getDate() != dt_current.getDate())\r\n\t\t{\r\n\t\t\tdt_prev_month.setDate(0);\r\n\t\t}\r\n\t\t\r\n\t\t// get same date in the next month\r\n\t\tvar dt_next_month = new Date(dt_current);\r\n\t\tdt_next_month.setMonth(dt_next_month.getMonth() + 1);\r\n\t\tif (dt_next_month.getDate() != dt_current.getDate())\r\n\t\t{\r\n\t\t\tdt_next_month.setDate(0);\r\n\t\t}\r\n\t\t\r\n\t\t// get first day to display in the grid for current month\r\n\t\tvar dt_firstday = new Date(dt_current);\r\n\t\tdt_firstday.setDate(1);\r\n\t\tdt_firstday.setDate(1 - (7 + dt_firstday.getDay() - obj_caller.NUM_WEEKSTART) % 7);\r\n\t\t\t\t\r\n\t\t// function passing selected date to calling window\r\n\t\tfunction set_datetime(n_datetime, b_close) \r\n\t\t{\r\n\t\t\tif (!obj_caller) \r\n\t\t\t{\r\n\t\t\t\treturn;\r\n\t\t\t}\r\n\t\t\r\n\t\t\tvar dt_datetime = new Date(n_datetime);\r\n\t\t\r\n\t\t\tif (!dt_datetime) \r\n");
      out.write("\t\t\t{\r\n\t\t\t\treturn;\r\n\t\t\t}\r\n\t\t\t\r\n\t\t\tif( b_close )\r\n\t\t\t{\r\n\t\t\t\twindow.close();\r\n\t\t\t\tobj_caller.target.value = formatDate(dt_datetime, obj_caller.pattern);\r\n\t\t\t}\r\n\t\t\telse \r\n\t\t\t{\r\n\t\t\t\tobj_caller.popup(dt_datetime.getTime());\r\n\t\t\t}\r\n\t\t}\t\r\n\t</script>\r\n</head>\r\n\r\n<body bgcolor=\"#f2f2f5\" topmargin=\"0\" leftmargin=\"0\" rightmargin=\"0\" bottommargin=\"0\" marginheight=\"0\" marginwidth=\"0\" style=\"height:100%\" onLoad=\"document.title=obj_caller.title;\">\r\n\t<table cellspacing=\"0\" cellpadding=\"0\" style=\"width:100%; height:100%;\">\r\n\r\n\t\t<!-- top blue bar -->\r\n\t\t<tr style=\"height:29px\" >\r\n\t\t\t<td style=\"width:7px;background-image:url(images/window_head_back.jpg);\"> &nbsp; </td>\r\n\t\t\t<td align=\"left\" style=\"background-image:url(images/window_head_back.jpg);vertical-align:middle; text-align:middle; white-space:nowrap; color:#ffffff;\">\r\n\t\t\t\t<script language=\"JavaScript\">\r\n\t\t\t\t\tdocument.write(obj_caller.header);\r\n\t\t\t\t</script>\r\n\t\t\t</td>\r\n\t\t\t<td style=\"background-image:url(images/window_head_back.jpg);width:7px\"> &nbsp; </td>\r\n\t\t</tr>\r\n\r\n\t\t<!-- blue round corners -->\r\n");
      out.write("\t\t<tr style=\"vertical-align:top;\">\r\n\t\t\t<td style=\"width:7px; font-size:1pt;\"><img src=\"images/logo-corner-ul.gif\"></td>\r\n\t\t\t<td style=\"width:100%; font-size:1pt;\"> &nbsp; </td>\r\n\t\t\t<td style=\"width:7px; font-size:1pt;\"><img src=\"images/logo-corner-ur.gif\"></td>\r\n\t\t</tr>\t\t\t\r\n\t\t\t\r\n\t\t<tr style=\"height:100%;\">\r\n\t\t\t<td></td>\r\n\t\t\t<td>\t\r\n\t\t\t\t<table style=\"width:100%; height:100%; border:10px solid #f2f2f5;\" cellspacing=\"0\" cellpadding=\"0\" >\r\n\t\t\t\t\t\r\n\t\t\t\t\t<!-- blue header bar corners -->\r\n\t\t\t\t\t<tr>\r\n\t\t\t\t\t\t<td><img src=\"images/bluebar_corner_small_ul.gif\"></td>\r\n\t\t\t\t\t\t<td style=\"width:100%; background-color:#3566F0;\"></td>\r\n\t\t\t\t\t\t<td><img src=\"images/bluebar_corner_small_ur.gif\"></td>\r\n\t\t\t\t\t</tr>\r\n\t\t\t\t\t\r\n\t\t\t\t\t<tr>\r\n\t\t\t\t\t\t<td colspan=\"3\">\r\n\t\t\t\t\t\t\t<!-- table containing the whole calendar with month picker - start -->\r\n\t\t\t\t\t\t\t<table class=\"listtable\" style=\"width:100%; border:0px;\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\">\r\n\t\t\t\t\t\t\t\r\n\t\t\t\t\t\t\t\t<tr style=\"height:21px;\">\r\n\t\t\t\t\t\t\t\t\t<script language=\"JavaScript\">\r\n\t\t\t\t\t\t\t\t\t\r\n\t\t\t\t\t\t\t\t\t// print weekdays titles\r\n");
      out.write("\t\t\t\t\t\t\t\t\tfor (var n=0; n<7; n++)\r\n\t\t\t\t\t\t\t\t\t{\r\n\t\t\t\t\t\t\t\t\t\tdocument.write('<th bgcolor=\"#e1e1e1\" align=\"center\">'+obj_caller.ARR_WEEKDAYS[(obj_caller.NUM_WEEKSTART+n)%7]+'</th>');\r\n\t\t\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t\t\t\tdocument.write('</tr>');\r\n\t\t\t\t\t\t\t\t\t\r\n\t\t\t\t\t\t\t\t\t// print calendar table\r\n\t\t\t\t\t\t\t\t\tvar dt_current_day = new Date(dt_firstday);\r\n\t\t\t\t\t\t\t\t\twhile (dt_current_day.getMonth() == dt_current.getMonth() ||\r\n\t\t\t\t\t\t\t\t\t\tdt_current_day.getMonth() == dt_firstday.getMonth()) \r\n\t\t\t\t\t\t\t\t\t{\r\n\t\t\t\t\t\t\t\t\t\t// print row heder\r\n\t\t\t\t\t\t\t\t\t\tdocument.write('<tr style=\"height:21px;\">');\r\n\t\t\t\t\t\t\t\t\t\tfor (var n_current_wday=0; n_current_wday<7; n_current_wday++) \r\n\t\t\t\t\t\t\t\t\t\t{\r\n\t\t\t\t\t\t\t\t\t\t\tif (dt_current_day.getDate() == dt_current.getDate() && dt_current_day.getMonth() == dt_current.getMonth())\r\n\t\t\t\t\t\t\t\t\t\t\t{\r\n\t\t\t\t\t\t\t\t\t\t\t\t// print current date\r\n\t\t\t\t\t\t\t\t\t\t\t\tdocument.write('<td style=\"padding-top:0px; padding-left:0px;\" bgcolor=\"#ffb6c1\" align=\"center\" width=\"14%\">');\r\n\t\t\t\t\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t\t\t\t\t\telse if (dt_current_day.getDay() == 0 || dt_current_day.getDay() == 6)\r\n");
      out.write("\t\t\t\t\t\t\t\t\t\t\t{\r\n\t\t\t\t\t\t\t\t\t\t\t\t// weekend days\r\n\t\t\t\t\t\t\t\t\t\t\t\tdocument.write('<td style=\"padding-top:0px; padding-left:0px;\" bgcolor=\"#e6eef9\" align=\"center\" width=\"14%\">');\r\n\t\t\t\t\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t\t\t\t\t\telse\r\n\t\t\t\t\t\t\t\t\t\t\t{\r\n\t\t\t\t\t\t\t\t\t\t\t\t// print working days of current month\r\n\t\t\t\t\t\t\t\t\t\t\t\tdocument.write('<td style=\"padding-top:0px; padding-left:0px;\" bgcolor=\"#ffffff\" align=\"center\" width=\"14%\">');\r\n\t\t\t\t\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t\t\t\t\r\n\t\t\t\t\t\t\t\t\t\t\tdocument.write('<a href=\"javascript:set_datetime('+dt_current_day.getTime() +', true);\">');\r\n\t\t\t\t\t\t\t\t\t\r\n\t\t\t\t\t\t\t\t\t\t\tif (dt_current_day.getMonth() == this.dt_current.getMonth())\r\n\t\t\t\t\t\t\t\t\t\t\t{\r\n\t\t\t\t\t\t\t\t\t\t\t\t// print days of current month\r\n\t\t\t\t\t\t\t\t\t\t\t\tdocument.write('<font color=\"#000000\">');\r\n\t\t\t\t\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t\t\t\t\t\telse \r\n\t\t\t\t\t\t\t\t\t\t\t{\r\n\t\t\t\t\t\t\t\t\t\t\t\t// print days of other months\r\n\t\t\t\t\t\t\t\t\t\t\t\tdocument.write('<font color=\"#606060\">');\r\n\t\t\t\t\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t\t\t\t\t\t\t\r\n\t\t\t\t\t\t\t\t\t\t\tdocument.write(dt_current_day.getDate()+'</font></a></td>');\r\n\t\t\t\t\t\t\t\t\t\t\tdt_current_day.setDate(dt_current_day.getDate()+1);\r\n");
      out.write("\t\t\t\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t\t\t\t\t// print row footer\r\n\t\t\t\t\t\t\t\t\t\tdocument.write('</tr>');\r\n\t\t\t\t\t\t\t\t\t}\r\n\t\t\t\t\t\t\t\t\t</script>\r\n\t\t\t\r\n\t\t\t\t\t\t\t\t<!-- footer containing month and arrows -->\r\n\t\t\t\t\t\t\t\t<tr>\r\n\t\t\t\t\t\t\t\t\t<td style=\"border:0px; padding:0px; background-color:#e1e1e1;\" colspan=\"7\">\r\n\t\t\t\t\t\t\t\t\t\t<table cellspacing=\"0\" cellpadding=\"0\" style=\"width:100%; padding:0px; border:0px;\" border=\"0\">\r\n\t\t\t\t\t\t\t\t\t\t\t<tr>\r\n\t\t\t\t\t\t\t\t\t\t\t\t<!-- lower left corner -->\r\n\t\t\t\t\t\t\t\t\t\t\t\t<td style=\"width:7px; padding:0px; vertical-align:bottom; height:23px;\"><img src=\"images/editortab_corner_bl.gif\"></td>\r\n\r\n\t\t\t\t\t\t\t\t\t\t\t\t<!-- previous year icon -->\r\n\t\t\t\t\t\t\t\t\t\t\t\t<td style=\"padding:0px;\">\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t<a href=\"#\" hidefocus=\"true\" style=\"text-decoration:none;\"\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tonMouseover=\"document.getElementById('id_btn_first_bg_left').style.backgroundImage = 'url(images/icons/footer_background_hover_l.gif)'; document.getElementById('id_btn_first_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_hover_m.gif)'; document.getElementById('id_btn_first_bg_right').style.backgroundImage = 'url(images/icons/footer_background_hover_r.gif)'; return true;\"\r\n");
      out.write("\t\t\t\t\t\t\t\t\t\t\t\t\t\tonMouseout=\"document.getElementById('id_btn_first_bg_left').style.backgroundImage = 'url(images/icons/footer_background_l.gif)'; document.getElementById('id_btn_first_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_m.gif)'; document.getElementById('id_btn_first_bg_right').style.backgroundImage = 'url(images/icons/footer_background_r.gif)'; return true;\"\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tonFocus=\"document.getElementById('id_btn_first_bg_left').style.backgroundImage = 'url(images/icons/footer_background_hover_l.gif)'; document.getElementById('id_btn_first_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_hover_m.gif)'; document.getElementById('id_btn_first_bg_right').style.backgroundImage = 'url(images/icons/footer_background_hover_r.gif)'; return true;\"\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tonBlur=\"document.getElementById('id_btn_first_bg_left').style.backgroundImage = 'url(images/icons/footer_background_l.gif)'; document.getElementById('id_btn_first_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_m.gif)'; document.getElementById('id_btn_first_bg_right').style.backgroundImage = 'url(images/icons/footer_background_r.gif)'; return true;\"\r\n");
      out.write("\t\t\t\t\t\t\t\t\t\t\t\t\t\tonClick=\"set_datetime(dt_prev_year.getTime());\">\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\">\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<tr>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td id=\"id_btn_first_bg_left\" style=\"width:3px; padding:0px;\" background=\"images/icons/footer_background_l.gif\"><div style=\"width:3px;\"></div></td>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td id=\"id_btn_first_bg_middle\" style=\"height:23px; padding:0px;\" background=\"images/icons/footer_background_m.gif\"><img src=\"images/icons/footer_first.gif\" alt=\"previous year\"></td>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td id=\"id_btn_first_bg_right\" style=\"width:3px; padding:0px;\" background=\"images/icons/footer_background_r.gif\"><div style=\"width:3px;\"></div></td>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t</tr>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t</table>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t</a>\r\n\t\t\t\t\t\t\t\t\t\t\t\t</td>\r\n\r\n\t\t\t\t\t\t\t\t\t\t\t\t<!-- previous month icon -->\r\n\t\t\t\t\t\t\t\t\t\t\t\t<td style=\"padding:0px;\">\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t<a href=\"#\" hidefocus=\"true\" style=\"text-decoration:none;\"\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tonMouseover=\"document.getElementById('id_btn_previous_bg_left').style.backgroundImage = 'url(images/icons/footer_background_hover_l.gif)'; document.getElementById('id_btn_previous_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_hover_m.gif)'; document.getElementById('id_btn_previous_bg_right').style.backgroundImage = 'url(images/icons/footer_background_hover_r.gif)'; return true;\"\r\n");
      out.write("\t\t\t\t\t\t\t\t\t\t\t\t\t\tonMouseout=\"document.getElementById('id_btn_previous_bg_left').style.backgroundImage = 'url(images/icons/footer_background_l.gif)'; document.getElementById('id_btn_previous_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_m.gif)'; document.getElementById('id_btn_previous_bg_right').style.backgroundImage = 'url(images/icons/footer_background_r.gif)'; return true;\"\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tonFocus=\"document.getElementById('id_btn_previous_bg_left').style.backgroundImage = 'url(images/icons/footer_background_hover_l.gif)'; document.getElementById('id_btn_previous_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_hover_m.gif)'; document.getElementById('id_btn_previous_bg_right').style.backgroundImage = 'url(images/icons/footer_background_hover_r.gif)'; return true;\"\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tonBlur=\"document.getElementById('id_btn_previous_bg_left').style.backgroundImage = 'url(images/icons/footer_background_l.gif)'; document.getElementById('id_btn_previous_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_m.gif)'; document.getElementById('id_btn_previous_bg_right').style.backgroundImage = 'url(images/icons/footer_background_r.gif)'; return true;\"\r\n");
      out.write("\t\t\t\t\t\t\t\t\t\t\t\t\t\tonClick=\"set_datetime(dt_prev_month.getTime())\">\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\">\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<tr>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td id=\"id_btn_previous_bg_left\" style=\"width:3px; padding:0px;\" background=\"images/icons/footer_background_l.gif\"><div style=\"width:3px;\"></div></td>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td id=\"id_btn_previous_bg_middle\" style=\"height:23px; padding:0px;\" background=\"images/icons/footer_background_m.gif\"><img src=\"images/icons/footer_previous.gif\" alt=\"previous month\"></td>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td id=\"id_btn_previous_bg_right\" style=\"width:3px; padding:0px;\" background=\"images/icons/footer_background_r.gif\"><div style=\"width:3px;\"></div></td>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t</tr>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t</table>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t</a>\r\n\t\t\t\t\t\t\t\t\t\t\t\t</td>\r\n\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t<!-- current month and year -->\r\n\t\t\t\t\t\t\t\t\t\t\t\t<td style=\"padding:0px; text-align:center; width:100%; white-space:nowrap;\"><font style=\"color:#0021c7; font-weight:bold;\"><script language=\"JavaScript\">document.write(obj_caller.ARR_MONTHS[dt_current.getMonth()] + ' ' + dt_current.getFullYear());</script></font></td>\r\n");
      out.write("\r\n\t\t\t\t\t\t\t\t\t\t\t\t<!-- next month icon -->\r\n\t\t\t\t\t\t\t\t\t\t\t\t<td style=\"padding:0px;\">\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t<a href=\"#\" hidefocus=\"true\" style=\"text-decoration:none;\"\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tonMouseover=\"document.getElementById('id_btn_next_bg_left').style.backgroundImage = 'url(images/icons/footer_background_hover_l.gif)'; document.getElementById('id_btn_next_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_hover_m.gif)'; document.getElementById('id_btn_next_bg_right').style.backgroundImage = 'url(images/icons/footer_background_hover_r.gif)'; return true;\"\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tonMouseout=\"document.getElementById('id_btn_next_bg_left').style.backgroundImage = 'url(images/icons/footer_background_l.gif)'; document.getElementById('id_btn_next_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_m.gif)'; document.getElementById('id_btn_next_bg_right').style.backgroundImage = 'url(images/icons/footer_background_r.gif)'; return true;\"\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tonFocus=\"document.getElementById('id_btn_next_bg_left').style.backgroundImage = 'url(images/icons/footer_background_hover_l.gif)'; document.getElementById('id_btn_next_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_hover_m.gif)'; document.getElementById('id_btn_next_bg_right').style.backgroundImage = 'url(images/icons/footer_background_hover_r.gif)'; return true;\"\r\n");
      out.write("\t\t\t\t\t\t\t\t\t\t\t\t\t\tonBlur=\"document.getElementById('id_btn_next_bg_left').style.backgroundImage = 'url(images/icons/footer_background_l.gif)'; document.getElementById('id_btn_next_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_m.gif)'; document.getElementById('id_btn_next_bg_right').style.backgroundImage = 'url(images/icons/footer_background_r.gif)'; return true;\"\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tonClick=\"set_datetime(dt_next_month.getTime())\"> \r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\">\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<tr>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td id=\"id_btn_next_bg_left\" style=\"width:3px; padding:0px;\" background=\"images/icons/footer_background_l.gif\"><div style=\"width:3px;\"></div></td>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td id=\"id_btn_next_bg_middle\" style=\"height:23px; padding:0px;\" background=\"images/icons/footer_background_m.gif\"><img src=\"images/icons/footer_next.gif\" alt=\"next month\"></td>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td id=\"id_btn_next_bg_right\" style=\"width:3px; padding:0px;\" background=\"images/icons/footer_background_r.gif\"><div style=\"width:3px;\"></div></td>\r\n");
      out.write("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t</tr>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t</table>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t</a>\r\n\t\t\t\t\t\t\t\t\t\t\t\t</td>\r\n\r\n\t\t\t\t\t\t\t\t\t\t\t\t<!-- next year icon -->\r\n\t\t\t\t\t\t\t\t\t\t\t\t<td style=\"padding:0px;\">\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t<a href=\"#\" hidefocus=\"true\" style=\"text-decoration:none;\"\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tonMouseover=\"document.getElementById('id_btn_last_bg_left').style.backgroundImage = 'url(images/icons/footer_background_hover_l.gif)'; document.getElementById('id_btn_last_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_hover_m.gif)'; document.getElementById('id_btn_last_bg_right').style.backgroundImage = 'url(images/icons/footer_background_hover_r.gif)'; return true;\"\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tonMouseout=\"document.getElementById('id_btn_last_bg_left').style.backgroundImage = 'url(images/icons/footer_background_l.gif)'; document.getElementById('id_btn_last_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_m.gif)'; document.getElementById('id_btn_last_bg_right').style.backgroundImage = 'url(images/icons/footer_background_r.gif)'; return true;\"\r\n");
      out.write("\t\t\t\t\t\t\t\t\t\t\t\t\t\tonFocus=\"document.getElementById('id_btn_last_bg_left').style.backgroundImage = 'url(images/icons/footer_background_hover_l.gif)'; document.getElementById('id_btn_last_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_hover_m.gif)'; document.getElementById('id_btn_last_bg_right').style.backgroundImage = 'url(images/icons/footer_background_hover_r.gif)'; return true;\"\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tonBlur=\"document.getElementById('id_btn_last_bg_left').style.backgroundImage = 'url(images/icons/footer_background_l.gif)'; document.getElementById('id_btn_last_bg_middle').style.backgroundImage = 'url(images/icons/footer_background_m.gif)'; document.getElementById('id_btn_last_bg_right').style.backgroundImage = 'url(images/icons/footer_background_r.gif)'; return true;\"\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\tonClick=\"set_datetime(dt_next_year.getTime())\"> \r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<table cellpadding=\"0\" cellspacing=\"0\" border=\"0\">\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<tr>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td id=\"id_btn_last_bg_left\" style=\"width:3px; padding:0px;\" background=\"images/icons/footer_background_l.gif\"><div style=\"width:3px;\"></div></td>\r\n");
      out.write("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td id=\"id_btn_last_bg_middle\" style=\"height:23px; padding:0px;\" background=\"images/icons/footer_background_m.gif\"><img src=\"images/icons/footer_last.gif\" alt=\"next year\"></td>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t<td id=\"id_btn_last_bg_right\" style=\"width:3px; padding:0px;\" background=\"images/icons/footer_background_r.gif\"><div style=\"width:3px;\"></div></td>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t</tr>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t</table>\r\n\t\t\t\t\t\t\t\t\t\t\t\t\t</a>\r\n\t\t\t\t\t\t\t\t\t\t\t\t</td>\r\n\r\n\t\t\t\t\t\t\t\t\t\t\t<!-- lower right corner -->\r\n\t\t\t\t\t\t\t\t\t\t\t\t<td style=\"width:20px; padding:0px; vertical-align:bottom;\"><img src=\"images/editortab_corner_br.gif\"></td>\r\n\t\t\t\t\t\t\t\t\t\t\t</tr>\r\n\t\t\t\t\t\t\t\t\t\t</table>\r\n\t\t\t\t\t\t\t\t\t</td>\t\t\r\n\t\t\t\t\t\t\t\t</tr>\r\n\t\t\t\t\t\t\t</table>\r\n\t\t\t\t\t\t<td>\r\n\t\t\t\t\t</tr>\r\n\t\t\t\t\t\t\t\t\t\t\r\n\t\t\t\t\t<!-- filler -->\r\n\t\t\t\t\t<tr>\r\n\t\t\t\t\t\t<td colspan=\"3\" height=\"100%\"></td>\r\n\t\t\t\t\t</tr>\r\n\r\n\t\t\t\t</table>\r\n\t\t\t\t\r\n\t\t\t</td>\r\n\t\t\t<td></td>\r\n\t\t</tr>\r\n\r\n\t\t<!-- empty grey space -->\r\n\t\t<tr style=\"vertical-align:bottom; height:7px;\">\r\n\t\t\t<td colspan=\"3\" style=\"width:100%; font-size:1pt;\"> &nbsp; </td>\r\n");
      out.write("\t\t</tr>\r\n\r\n\t</table>\r\n\r\n</body>\r\n\r\n</html>\r\n\r\n");
    } catch (java.lang.Throwable t) {
      if (!(t instanceof javax.servlet.jsp.SkipPageException)){
        out = _jspx_out;
        if (out != null && out.getBufferSize() != 0)
          try {
            if (response.isCommitted()) {
              out.flush();
            } else {
              out.clearBuffer();
            }
          } catch (java.io.IOException e) {}
        if (_jspx_page_context != null) _jspx_page_context.handlePageException(t);
        else throw new ServletException(t);
      }
    } finally {
      _jspxFactory.releasePageContext(_jspx_page_context);
    }
  }
}
