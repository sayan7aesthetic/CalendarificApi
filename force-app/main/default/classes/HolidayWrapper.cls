public class HolidayWrapper {
	public cls_meta meta;
	public cls_response response;
	public class cls_meta {
		public Integer code;	
	}
	public class cls_response {
		public cls_holidays[] holidays;
	}
	public class cls_holidays {
		public String name;	
		public String description;	
		public cls_country country;
		public cls_date clsdate;
		public List<String> type;
		public String primary_type;	
		public String canonical_url;	
		public String urlid;	
		public String locations;	
		public String states;	
	}
	class cls_country {
		public String id;	
		public String name;	
	}
	public class cls_date {
		public String iso;	
		public cls_datetime clsdatetime;
        public cls_timezone timezone;
	}
	class cls_datetime {
		public Integer year;	
		public Integer month;	
		public Integer day;	
	}
    class cls_timezone {
		public String offset;	
		public String zoneabb;	
		public String zoneoffset;
        public Integer zonedst;
        public Integer zonetotaloffset;
	}
	
}