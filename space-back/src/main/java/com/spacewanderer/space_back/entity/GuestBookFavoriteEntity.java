package com.spacewanderer.space_back.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@Entity(name = "guest_book_favorite")
@Table(name = "guest_book_favorite")
public class GuestBookFavoriteEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "favorite_id")
    private Long favoriteId;

    @ManyToOne
    @JoinColumn(name = "guest_book_id", referencedColumnName = "guest_book_id")
    private GuestBookEntity guestBook;

    @ManyToOne
    @JoinColumn(name = "user_unique_id", referencedColumnName = "user_unique_id")
    private UserEntity userUniqueId;

    // 생성자
    public GuestBookFavoriteEntity(Long favoriteId, GuestBookEntity guestBook, UserEntity userUniqueId) {
        this.favoriteId = favoriteId; 
        this.guestBook = guestBook;
        this.userUniqueId = userUniqueId;
    }
}
