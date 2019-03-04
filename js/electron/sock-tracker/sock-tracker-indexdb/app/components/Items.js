import React from 'react';
import Item from './Item';

const Items = ({title, items, onCheckOff, onDelete}) => {
    return (
        <selection className="Items">
            <h2>{title}</h2>
            {items.map(item => (
                <Item key={item.id}
                      onCheckOff={() => onCheckOff(item)}
                      onDelete={() => onDelete(item)}
            {...item}
            />
            ))}
        </selection>
    );
};

export default Items;