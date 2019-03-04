import React, {Component} from 'react';
import Items from './Items';
import NewItem from './NewItem';

class Application extends Component {
    constructor(props) {
        super(props);
        this.state = {
            items: []
            // items: [{ 
            //     value: 'Pants', 
            //     id: Date.now(), 
            //     packed: false
            // }]
        };
        this.fetchItems = this.fetchItems.bind(this);
        this.deleteItem = this.deleteItem.bind(this);
        this.deleteUnpackedItems = this.deleteUnpackedItems.bind(this);
        this.addItem = this.addItem.bind(this);
        this.markAsPacked = this.markAsPacked.bind(this);
        this.markAllAsUnpacked = this.markAllAsUnpacked.bind(this);
    }
    componentDidMount() {
        this.fetchItems();
    }

    fetchItems() {
        this.props.database("items").select()
                  .then(items=>this.setState({items}))
                  .catch(console.error);
    }

    deleteItem(item) {
        this.props.database("items").where("id", item.id)
                                    .delete()
                                    .then(this.fetchItems)
                                    .catch(console.error);
    };

    deleteUnpackedItems() {
        this.props.database("items").where("packed", false)
                                    .delete()
                                    .then(this.fetchItems)
                                    .catch(console.error);
    };

    addItem(item) {
        //this.setState({items: [item, ...this.state.items]});
        this.props.database("items").insert(item).then(this.fetchItems);
    }
    markAsPacked(item) {
        this.props.database("items").where("id", "=", item.id)
                                    .update({packed: !item.packed})
                                    .then(this.fetchItems)
                                    .catch(console.error);
        // const otherItems = this.state.items.filter(o=>o.id !== item.id);
        // const updatedItem = {...item, packed: !item.packed};
        // this.setState({items: [updatedItem, ...otherItems]})
    }
    markAllAsUnpacked() {
        this.props.database("items").select()
                                    .update({packed: false})
                                    .then(this.fetchItems)
                                    .catch(console.error);        
        // const items = this.state.items.map(item=> ({...item, packed: false}));
        // this.setState({items});
    }

    render() {
        const {items} = this.state;
        const unpackedItems = items.filter(item => !item.packed);
        const packedItems = items.filter(item => item.packed);
        return (
            <div className="Application">
                <NewItem onSubmit={this.addItem} />
                <Items title="Unpacked Items"
                    items={unpackedItems}
                    onCheckOff={this.markAsPacked} 
                    onDelete={this.deleteItem} />
                <Items title="Packed Items"
                    items={packedItems}
                    onCheckOff={this.markAsPacked} 
                    onDelete={this.deleteItem} />
                <button className="button full-width" 
                        onClick={this.markAllAsUnpacked}>Mark All As Unpacked</button>
                <button className="button full-width secondary" 
                        onClick={this.deleteUnpackedItems}>Remove Unpacked Items</button>
            </div>
        );
    }
}

export default Application;