new Vue({
    el: "#method",
    data: {
        status: ""
    },
    methods: {
        updateStatus(event) {
            this.button = this.button === 2 ? 0 : this.button + 1;
            const buttons = ['left', 'middle', 'right'];
            this.status = `you clicked the ${buttons[event.button]}`;
        }
    }
});
new Vue({
    el: "#inputapp",
    data: {
        text: "Good molly"
    }
});
new Vue({
    el: "#main",
    computed: {
        sortedEmployees() {
            return this.employees.sort((a, b) => a[this.sortBy].localeCompare(b[this.sortBy]));
        }
    },
    data: { 
        heading: "Staff Directory",
        sortBy: "firstName",
        employees: [{            
            "firstName": "amelia",
            "lastName": "austin",
            "photoUrl": "https://randomuser.me/api/portraits/thumb/women/9.jpg",
            "email": "amelia.austin@example.com",
            "phone": "(651)-507-3705",
            "department": "Engineering"
        },{
            "firstName": "bobbie",
            "lastName": "murphy",
            "photoUrl": "https://randomuser.me/api/portraits/thumb/women/77.jpg",
            "email": "bobbie.murphy@example.com",
            "phone": "(925)-667-7604",
            "department": "Management"
        },{
            "firstName": "cindy",
            "lastName": "teumatilda",
            "photoUrl": "https://randomuser.me/api/portraits/thumb/women/76.jpg",
            "email": "cindy.teumatilda@example.com",
            "phone": "(925)-637-7624",
            "department": "Operations"
        },{
            "firstName": "zuzzana",
            "lastName": "shasha",
            "photoUrl": "https://randomuser.me/api/portraits/thumb/women/73.jpg",
            "email": "zuzzana.shasha@example.com",
            "phone": "(925)-667-1611",
            "department": "Management"
        },{
            "firstName": "equity-bullabo",
            "lastName": "evena",
            "photoUrl": "https://randomuser.me/api/portraits/thumb/women/71.jpg",
            "email": "equity-bullabo.evena@example.com",
            "phone": "(925)-667-7604",
            "department": "Operations"
        }]
    }
});        
var example1 = new Vue({
    el: '#example-1',
    data: { items: [
        { message: 'Foo' },
        { message: 'Bar' }]
    }
});    
new Vue({
    el: "#head-first",
    data: {
        heading: "this is a heading"
    }
});
new Vue({
    el: "#app",
    data: {
        price: 25
    }
});